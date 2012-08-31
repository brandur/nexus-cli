module Nexus
  # code borrowed from Slides
  module Unparser
    extend self

    def quote_string(k, v)
      # try to find a quote style that fits
      if !v.include?('"')
        %{#{k}="#{v}"}
      elsif !v.include?("'")
        %{#{k}='#{v}'}
      else
        %{#{k}="#{v.gsub(/"/, '\\"')}"}
      end
    end

    def unparse(attrs)
      attrs.map { |k, v| unparse_pair(k, v) }.compact.join(" ")
    end

    def unparse_pair(k, v)
      # only quote strings if they include whitespace
      if v == nil
        nil
      elsif v.is_a?(String) && v =~ /\s/
        quote_string(k, v)
      elsif v == true
        k
      else
        "#{k}=#{v}"
      end
    end
  end
end
