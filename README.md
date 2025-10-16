# requestly

An open-source library for making type-safe requests in Luau.

## Installation

pesde (Roblox and lune):

1. Run the install command

```sh
pesde add femphilic/requestly
pesde install
```

Wally (Roblox only):

1. Add to TOML file (`wally.toml`)

```toml
[dependencies]
requestly = "femphilic/requestly@0.2.0" # change to the appropriate version
```

2. Run the install command

```sh
wally install
```

## Usage

requestly hsa a simple API:

```luau
-- encode a url
local encodedUrl = requestly.encodeUrl("テスト") -- "%E3%83%86%E3%82%B9%E3%83%88"

local jsonObj = {
  name = {
    first = "John",
    last = "Doe",
  },
  age = 35,
  job = "Software Engineer at Roblox",
}

-- encode json
local encodedJson = requestly.encodeJson(jsonObj) -- "{"name":{"first":"John","last":"Doe"},"age":35,"job":"Software Engineer at Roblox"}"
-- decode json
local decodedJson = requestly.decodeJson(
  encodedJson, -- json string
  jsonObj -- "validation" object (decoded json will be validated against this object using greentea)
) --[[
  {
    name = {
      first = "John",
      last = "Doe",
    },
    age = 35,
    job = "Software Engineer at Roblox"
  }
]]--

local response = requestly:request({
	url = "https://example.com",
	method = "GET",
	jsonDecode = true,
	compress = "gzip",
	headers = {
		["Authorization"] = "Bearer 1234567890",
	},
}, decodedJson)

print(response)
```
