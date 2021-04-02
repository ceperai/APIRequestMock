# APIRequestMock

Tool to mock api responses. Just register APIRequestMock in url session. `ResourceNames` is an array of json 
files with request responses in Bundle.main.
``` swift
    let configuration = URLSessionConfiguration.default
    APIRequestMock.register(resourceNames: ["responses.json"], in: configuration)
```
Here is an example of `resources.json` file:
```swift
"""
[
    {
        "enabled": true,
        "uri": ["https://sampleurl.io/api/v1/items"],
        "headers": {"api_token": "123"},
        "comment": "Sample mocked response",
        "value": [
            { "value": 1 },
            { "value": 2 },
            { "value": 3 },
        ]
    }
]
"""
```
