require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../../lib/exceptional/utils/http_utils'

describe Exceptional::Utils::HttpUtils do

  include Exceptional::Utils::HttpUtils

  OK_RESPONSE_BODY = "OK-RESP-BODY" unless defined?(OK_RESPONSE_BODY)

  describe "sending data " do

    it "should return response body if successful" do

      mock_http = mock(Net::HTTP)
      Net::HTTP.should_receive(:new).with("getexceptional.com", 80).once.and_return(mock_http)

      mock_http_response= mock(Net::HTTPSuccess)
      mock_http_response.should_receive(:kind_of?).with(Net::HTTPSuccess).once.and_return(true)
      mock_http_response.should_receive(:body).once.and_return(OK_RESPONSE_BODY)

      mock_http.should_receive(:start).once.and_return(mock_http_response)

      http_call_remote(Exceptional.remote_host?, Exceptional.remote_port?, Exceptional.api_key, Exceptional.ssl_enabled?, :message, "data", Exceptional.log).should == OK_RESPONSE_BODY
    end

    it "should raise error if network problem during sending exception" do

      mock_http = mock(Net::HTTP)
      Net::HTTP.should_receive(:new).with("getexceptional.com", 80).once.and_return(mock_http)

      mock_http_response= mock(Net::HTTPSuccess)

      mock_http.should_receive(:start).once.and_raise(IOError)
      mock_log = mock(Logger)
      mock_log.should_receive(:send).twice

      lambda{http_call_remote(Exceptional.remote_host?, Exceptional.remote_port?, Exceptional.api_key, Exceptional.ssl_enabled?, :message, "data", mock_log)}.should raise_error(IOError)
    end

    it "should raise Exception if sending exception unsuccessful" do

      mock_http = mock(Net::HTTP)
      Net::HTTP.should_receive(:new).with("getexceptional.com", 80).once.and_return(mock_http)

      mock_http_response= mock(Net::HTTPInternalServerError)
      mock_http_response.should_receive(:kind_of?).with(Net::HTTPSuccess).once.and_return(false)
      mock_http_response.should_receive(:code).once.and_return(501)
      mock_http_response.should_receive(:message).once.and_return("Internal Server Error")

      mock_http.should_receive(:start).once.and_return(mock_http_response)
      mock_log = mock(Logger)
      mock_log.should_receive(:send).twice
      
      lambda{http_call_remote(Exceptional.remote_host?, Exceptional.remote_port?, Exceptional.api_key, Exceptional.ssl_enabled?, :message, "data", mock_log)}.should raise_error(Exceptional::Utils::HttpUtils::HttpUtilsException)
    end
  end
end
