module Nexus
  class Client
    include Term::ANSIColor

    def initialize(http_api_url, http_api_key)
      url_with_key = http_api_url.gsub(%r{^https?://}, "https://:#{http_api_key}@")
      @api = Excon.new(url_with_key, ssl_verify_peer: false)

      @last_id = 0
    end

    def run
      loop do
        fetch
        sleep(10)
      end
    end

    private

    def colorize_source
      source = yield
      case source
      when /^github/
        black { on_white { source } }
      when /^hackernews/
        black { on_yellow { source } }
      when /^twitter/
        on_blue { source }
      else source
      end
    end

    def fetch
      begin
        response = @api.get(path: "/events", expects: 200,
          query: { since: @last_id + 1 })
        events = MultiJson.decode(response.body)
        events.sort_by { |e| e["id"] }.each do |event|
          if event["id"] > @last_id
            puts Unparser.unparse(format(event))
            @last_id = event["id"]
          end
        end
      rescue
        puts "request_failed"
        #puts $!
      end
    end

    def format(event)
      {
        colorize_source { format_source(event) } => true,
        title: event["title"] ? bold { cyan { event["title"] } } : nil,
        content: event["content"] ? green { event["content"] } : nil,
        url: event["url"],
        published_at: event["published_at"],
      }.merge(event["metadata"] ? event["metadata"] : {})
    end

    def format_source(event)
      if user = event["metadata"]["user"]
        event["source"] + "@" + user
      else
        event["source"]
      end
    end
  end
end
