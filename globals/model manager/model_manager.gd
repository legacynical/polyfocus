extends Node

var api_key: String = OS.get_environment("OPENAI_API_KEY")
var url: String = "https://api.openai.com/v1/chat/completions"
var temperature: float = 0.5
var max_tokens: int = 1024
var headers: PackedStringArray = ["Content-Type: application/json", "Authorization: Bearer " + api_key]
var model: String = "gpt-4o-mini"
var messages: Array = []
var httpRequest: HTTPRequest

func _ready() -> void:
	httpRequest = HTTPRequest.new()
	add_child(httpRequest)
	httpRequest.connect("request_completed", Callable(self, "_on_request_completed"))
	dialogue_request("Give me a monologue on how to manage focus on diverse topics.")
	
func dialogue_request (player_dialogue: String) -> void:
	messages.append({
		"role": "user",
		"content": player_dialogue
	})
	
	var body = JSON.stringify({
		"messages": messages,
		"temperature": temperature,
		"max_tokens": max_tokens,
		"model": model
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
