require 'rubygems'
require 'sinatra'
require 'json'
require 'rest-client'

set :facebook_page_access_token, "xxx"

get '/messenger' do
  if params["hub.mode"] == "subscribe"
    return params["hub.challenge"]
  end
end

post '/messenger' do
  params = JSON.parse(request.body.read) # incoming message parameters
  facebook_user_id = params["entry"][0]["messaging"][0]["sender"]["id"] # user id of sender
  message = params["entry"][0]["messaging"][0]["message"] # message contents

  # check if incoming webhook contains a message
  if !message.nil? && !message["text"].nil?
    # call send_message() method
    return send_message({
      # set recipient as the sender of the original message
      "recipient" => {
        "id"=> facebook_user_id
      },
      # set the message contents as the incoming message text
      "message"=>{
        "text"=> message["text"]
      }
    })
  end
end

# send message via Messenger Send API
def send_message(payload)
  begin
    response = RestClient.post "https://graph.facebook.com/v2.6/me/messages?access_token=#{settings.facebook_page_access_token}", payload.to_json, :content_type => :json, :accept => :json
  rescue => e
    return e
  end
end