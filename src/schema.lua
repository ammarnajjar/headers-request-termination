local typedefs = require "kong.db.schema.typedefs"


local is_present = function(v)
  return type(v) == "string" and #v > 0
end


return {
  name = "kong-request-allow",
  fields = {
    { protocols = typedefs.protocols_http },
    { config = {
        type = "record",
        fields = {
          { status_code = { type = "integer",
            required = true,
            default = 503,
            between = { 100, 599 },
          }, },
          { message = { type = "string" }, },
          { content_type = { type = "string" }, },
          { body = { type = "string" }, },
          { echo = { type = "boolean", required = true, default = false }, },
          { trigger_key = { type = "string" }, },
          { trigger_value = { type = "string" }, }
        },
        custom_validator = function(config)
          if is_present(config.message)
          and(is_present(config.content_type)
              or is_present(config.body)) then
            return nil, "message cannot be used with content_type or body"
          end
          if is_present(config.content_type)
          and not is_present(config.body) then
            return nil, "content_type requires a body"
          end
          if config.echo and (
            is_present(config.content_type) or
            is_present(config.body)) then
            return nil, "echo cannot be used with content_type and body"
          end
          if (is_present(config.trigger_key) and not is_present(config.trigger_value)) or
              (not is_present(config.trigger_key) and (is_present(config.trigger_value)))
          then
            return nil, "allow trigger needs both key and a value"
          end
          return true
        end,
      },
    },
  },
}
