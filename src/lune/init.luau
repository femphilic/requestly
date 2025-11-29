--!strict
--!optimize 2
--!native

local net = require("@lune/net")
local serde = require("@lune/serde")
local GreenTea = require("@self/GreenTea")

local requestly = {} :: Requestly

function requestly.encodeUrl(url)
	return net.urlEncode(url, false)
end

function requestly.decodeJson<T>(jsonString: string, validation: T?): T
	local json = serde.decode("json", jsonString)
	if validation then
		local gtValidation = GreenTea.isGreenTeaType(validation) and (validation :: any) :: GreenTea.Type
			or GreenTea.build(validation)
		gtValidation:assert(json)
	end
	return json
end

function requestly.encodeJson<T>(json: T): string
	return serde.encode("json", json, false)
end

export type RequestMethodWithNoBody = "GET" | "HEAD"
export type RequestMethodWithBody = "POST" | "PUT" | "DELETE" | "OPTIONS" | "PATCH"
export type RequestMethod = RequestMethodWithNoBody | RequestMethodWithBody

export type RequestHeaderKey = string
export type RequestHeaderValue = string | { string }

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

function requestly:request<T>(opts: RequestOptions, validation: T?): Response<T>
	local jsonDecode = opts.jsonDecode or false
	local method = opts.method or "GET"
	local compress = opts.compress or "gzip" :: RequestCompression
	local ogHeaders = opts.headers or {} :: RequestHeaders
	local headers = table.clone(ogHeaders)
	headers["Accept-Encoding"] = compress
	if method == "GET" or method == "HEAD" then
		assert(opts.body == nil, `[requestly] this request method ({opts.method}) cannot have a body`)
	end

	local httpRes = net.request({
		url = opts.url,
		method = method,
		body = opts.body,
		headers = headers :: net.HttpHeaderMap,
		options = {
			decompress = true,
		},
	})

	local res: Response<T> = {
		body = httpRes.body,
		headers = httpRes.headers :: ResponseHeaders,
		status = {
			code = httpRes.statusCode,
			message = httpRes.statusMessage,
		},
		success = httpRes.statusCode >= 200 and httpRes.statusCode < 300,
	}

	if jsonDecode and httpRes.body then
		assert(type(validation) == "table", "[requestly] validation must be a table when using jsonDecode")
		local success, decoded = xpcall(function()
			return self.decodeJson(httpRes.body, validation)
		end, function()
			print("[requestly] JSON decoding failed validation")
			return self.decodeJson(httpRes.body)
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
