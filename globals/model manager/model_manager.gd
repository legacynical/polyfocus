extends Node

var api_key: String = OS.get_environment("OPENAI_API_KEY")
var url: String = "https://api.openai.com/v1/chat/completions"
var headers: PackedStringArray = ["Content-Type: application/json", "Authorization: Bearer " + api_key]

var model: PackedStringArray = [
	"gpt-4o-mini", # most cost-efficient small model with vision capabilities
	"gpt-4o", # most advanced multimodal with stronger vision capabilities
	"o1-mini", # fast, cost-efficient reasoning model tailored to coding, math, and science
	"o1-preview" # new reasoning model for complex tasks
]
var id: int = 0 # model[id] initialized to "gpt-4o-mini"

var max_completion_tokens: int = 1024
var temperature: float = 0.5 # value between 0 and 2
var store: bool = true # to store chat completions in dev dashboard
var metadata: Dictionary = {} # custom tags to filter in dev dashboard
var messages: Array = []
var prompt: String = ""

var httpRequest: HTTPRequest

func _ready() -> void:
	httpRequest = HTTPRequest.new()
	add_child(httpRequest)
	httpRequest.connect("request_completed", Callable(self, "_on_request_completed"))
	callGPT("Give me a monologue on how to manage focus on diverse topics.")
	
	metadata = {
	"application": "polyfocus",
	"version": "0.1.0-alpha"
	}
	
func callGPT(prompt) -> void:
	messages.append({
		"role": "user",
		"content": prompt
	})
	
	var body = JSON.stringify({
		"model": model[id],
		"max_completion_tokens": max_completion_tokens,
		"temperature": temperature,
		"store": store,
		"metadata": metadata,
		"messages": messages
	})

	var send_request = httpRequest.request(url, headers, HTTPClient.METHOD_POST, body)
	if send_request != OK:
		print("Send request failed! :( Error Code: " + str(send_request))

func _on_request_completed (result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var json = JSON.new()
	var parse_error = json.parse(body.get_string_from_utf8())
	if parse_error == OK:
		var response = json.get_data()
		print("Full response: \n", response)
		
		if response.has("choices") and response["choices"].size() > 0:
			var choice = response["choices"][0]
			if choice.has("message") and choice["message"].has("content"):
				var message = choice["message"]["content"]
				print("Model Output: \n", message)
				messages.append({
					"role": "assistant",
					"content": message
				})
			else:
				push_error('Unexpected reponse. Wrong structure.')
		else:
			push_error('Unexpected responce. No "choices" in response.')
	else:
		push_error('Parse JSON failed. Error code: ' + str(parse_error))
	
##typical error response
# { "error": 
#	{
#	"message": "You exceeded your current quota, please check your plan and billing details. For more information on this error, read the docs: https://platform.openai.com/docs/guides/error-codes/api-errors.", 
#	"type": "insufficient_quota", 
#	"param": <null>, 
#	"code": "insufficient_quota" 
#	} 
# }
