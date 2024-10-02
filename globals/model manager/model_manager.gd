extends Node

var api_key: String = OS.get_environment("OPENAI_API_KEY")
var url: String = "https://api.openai.com/v1/chat/completions"
var temperature: float = 0.5
var max_tokens: int = 1024
var headers: Array = ["Content-Type: application/json", "Authorization: Bearer " + api_key]
var model: String = "gpt-4o-mini"
var messages: Array = []
var request: HTTPRequest

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	request = HTTPRequest.new()
	add_child(request)
	request.connect("request_completed", _on_request_completed)

	dialogue_request("Give me a monologue on how to manage focus on diverse topics.")
	
func dialogue_request (player_dialogue):
	messages.append({
		"role": "user",
		"content": player_dialogue
		})
	
	var body = JSON.new().stringify({
		"messages": messages,
		"temperature": temperature,
		"max_tokens": max_tokens,
		"model": model
	})

	var send_request = request.request(url, headers, HTTPClient.METHOD_POST, body)
	
	if send_request != OK:
		print("Request Error :(")

func _on_request_completed (result, response_code, headers, body) -> void:
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	print (response)
	#var message = response["choices"][0]["message"]["content"]
	#print(message)
	
##typical error response
# { "error": 
#	{
#	"message": "You exceeded your current quota, please check your plan and billing details. For more information on this error, read the docs: https://platform.openai.com/docs/guides/error-codes/api-errors.", 
#	"type": "insufficient_quota", 
#	"param": <null>, 
#	"code": "insufficient_quota" 
#	} 
# }
