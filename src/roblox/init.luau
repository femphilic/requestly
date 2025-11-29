--!strict
--!optimize 2
--!native

local http = game:GetService("HttpService")
local GreenTea = require(script.GreenTea)

local requestly = {} :: Requestly

function requestly.encodeUrl(url)
	return http:UrlEncode(url)
end

function requestly.decodeJson<T>(jsonString: string, validation: T?): T
	local json = http:JSONDecode(jsonString)
	if validation then
		local gtValidation = GreenTea.isGreenTeaType(validation) and (validation :: any) :: GreenTea.Type
			or GreenTea.build(validation)
		gtValidation:assert(json)
	end
	return json
end

function requestly.encodeJson<T>(json: T): string
	return http:JSONEncode(json)
end

export type RequestMethodWithNoBody = "GET" | "HEAD"
export type RequestMethodWithBody = "POST" | "PUT" | "DELETE" | "OPTIONS" | "PATCH"
export type RequestMethod = RequestMethodWithNoBody | RequestMethodWithBody

export type RequestHeaderKey = string
export type RequestHeaderValue = string | Secret

export type RequestHeaders = {
	[RequestHeaderKey]: RequestHeaderValue,
}

export type RequestCompression = "gzip" | "none"

export type RequestOptions =
	{
		url: string,
		method: RequestMethodWithNoBody?,
		headers: RequestHeaders?,
		body: nil,
		compress: RequestCompression?,
		jsonDecode: boolean?,
	}
	| {
		url: string,
		method: RequestMethodWithBody,
		headers: RequestHeaders?,
		body: string?,
		compress: RequestCompression?,
		jsonDecode: boolean?,
	}

export type ResponseHeaderKey = string
export type ResponseHeaderValue = string

export type ResponseHeaders = {
	[ResponseHeaderKey]: ResponseHeaderValue,
}

export type ResponseStatus = {
	code: number,
	message: string,
}

export type Response<T> = {
	body: T,
	headers: ResponseHeaders,
	status: ResponseStatus,
	success: boolean,
}

local compressionMap: { [RequestCompression]: Enum.HttpCompression } = {
	none = Enum.HttpCompression.None,
	gzip = Enum.HttpCompression.Gzip,
}

function requestly:request<T>(opts: RequestOptions, validation: T?): Response<T>
	local jsonDecode = opts.jsonDecode or false
	local method = opts.method or "GET"
	local compressString = opts.compress or "gzip" :: RequestCompression
	local compress = compressionMap[compressString]
	if method == "GET" or method == "HEAD" then
		assert(opts.body == nil, `[{script.Name}] this request method ({opts.method}) cannot have a body`)
	end

	local httpRes = http:RequestAsync({
		Url = opts.url,
		Method = opts.method,
		Headers = opts.headers,
		Body = opts.body,
		Compress = compress,
	})

	local res: Response<T> = {
		body = httpRes.Body,
		headers = httpRes.Headers,
		status = {
			code = httpRes.StatusCode,
			message = httpRes.StatusMessage,
		},
		success = httpRes.Success,
	}

	if jsonDecode and httpRes.Body then
		assert(type(validation) == "table", `[{script.Name}] validation must be a table when using jsonDecode`)
		local success, decoded = xpcall(function()
			return self.decodeJson(httpRes.Body, validation)
		end, function()
			warn(`[{script.Name}] JSON decoding failed validation`)
			return self.decodeJson(httpRes.Body)
		end)
		res.body = decoded :: T
		res.success = success
	end

	return res
end

requestly.GreenTea = {
	isGreenTeaType = GreenTea.isGreenTeaType,
	isGtType = GreenTea.isGtType,
	boolean = GreenTea.boolean,
	bool = GreenTea.bool,
	none = GreenTea.none,
	literal = function<T>(value: T & (string | boolean)): T
		return GreenTea.literal(value)
	end,
	number = GreenTea.number,
	string = GreenTea.string,
	table = GreenTea.table,
	struct = GreenTea.struct,
	array = GreenTea.array,
	dictionary = GreenTea.dictionary,
	union = GreenTea.union,
	oneOf = GreenTea.oneOf,
	intersection = GreenTea.intersection,
	allOf = GreenTea.allOf,
	optional = GreenTea.optional,
	opt = GreenTea.opt,
}

export type Requestly = {
	encodeUrl: (url: string) -> string,
	decodeJson: <T>(jsonString: string, validation: T?) -> T,
	encodeJson: <T>(json: T) -> string,
	request: <T>(self: Requestly, opts: RequestOptions, validation: T?) -> Response<T>,
	GreenTea: {
		isGreenTeaType: typeof(GreenTea.isGreenTeaType),
		isGtType: typeof(GreenTea.isGtType),
		boolean: typeof(GreenTea.boolean),
		bool: typeof(GreenTea.bool),
		none: typeof(GreenTea.none),
		literal: <T>(value: T & (string | boolean)) -> T,
		number: typeof(GreenTea.number),
		string: typeof(GreenTea.string),
		table: typeof(GreenTea.table),
		struct: typeof(GreenTea.struct),
		array: typeof(GreenTea.array),
		dictionary: typeof(GreenTea.dictionary),
		union: typeof(GreenTea.union),
		oneOf: typeof(GreenTea.oneOf),
		intersection: typeof(GreenTea.intersection),
		allOf: typeof(GreenTea.allOf),
		optional: typeof(GreenTea.optional),
		opt: typeof(GreenTea.opt),
	},
}

return requestly
