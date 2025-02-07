-- dep
local ansicolors = require 'ansicolors'

-- vanilla
local va_conf = require 'vanilla.sys.config'
local helpers = require 'vanilla.v.libs.utils'

local gitignore = [[
# vanilla
client_body_temp
fastcgi_temp
logs
proxy_temp
tmp
uwsgi_temp

# vim
.*.sw[a-z]
*.un~
Session.vim

# textmate
*.tmproj
*.tmproject
tmtags

# OSX
.DS_Store
._*
.Spotlight-V100
.Trashes
*.swp
]]


local index_controller = [[
local IndexController = {}

function IndexController:index()
    local view = self:getView()
    local p = {}
    p['vanilla'] = 'Welcome To Vanilla...'
    p['zhoujing'] = 'Power by Openresty'
    view:assign(p)
    return view:display()
end

return IndexController
]]


local index_tpl = [[
<!DOCTYPE html>
<html>
<body>
  <img src="http://m1.sinaimg.cn/maxwidth.300/m1.sinaimg.cn/ca65fa784406a36ba4fc41d14e21661e_1364_1494.png">
  <h1><a href = 'https://github.com/idevz/vanilla'>{{vanilla}}</a></h1><h5>{{zhoujing}}</h5>
</body>
</html>
]]


local error_controller = [[
local ErrorController = {}

function ErrorController:error()
    local view = self:getView()
    view:assign(self.err)
    return view:display()
end

return ErrorController
]]


local error_tpl = [[
<!DOCTYPE html>
<html>
<body>
  <h1>{{status}}</h1>
  {% for k, v in pairs(body) do %}
      {% if k == 'message' then %}
      <h4>{{k}}  =>  {{v}}</h4>
      {% else %}
      <h5>{{k}}  :  {{v}}</h5>
      {% end %}
  {% end %}
</body>
</html>
]]

local dao = [[
-- local TableDao = require('vanilla.v.model.dao'):new()
local TableDao = {}

function TableDao:set(key, value)
    self.__cache[key] = value
    return true
end

function TableDao:new()
    local instance = {
        set = self.set,
        __cache = {}
    }
    setmetatable(instance, TableDao)
    return instance
end

function TableDao:__index(key)
    local out = rawget(rawget(self, '__cache'), key)
    if out then return out else return false end
end
return TableDao
]]

local service = [[
-- local UserService = require('vanilla.v.model.service'):new()
local table_dao = require('application.models.dao.table'):new()
local UserService = {}

function UserService:get()
    table_dao:set('zhou', 'j')
    return table_dao.zhou
end

return UserService
]]


local bootstrap = [[
local Bootstrap = require('vanilla.v.bootstrap'):new(dispatcher)

function Bootstrap:initErrorHandle()
    self.dispatcher:setErrorHandler({controller = 'error', action = 'error'})
end

function Bootstrap:initRoute()
    local router = require('vanilla.v.routes.simple'):new(self.dispatcher:getRequest())
    self.dispatcher.router = router
end

function Bootstrap:initView()
end

function Bootstrap:boot_list()
    return {
        Bootstrap.initErrorHandle,
        Bootstrap.initRoute,
        Bootstrap.initView
    }
end

return Bootstrap
]]


local application_conf = [[
local Appconf={}
Appconf.name = '{{APP_NAME}}'

Appconf.route='vanilla.v.routes.simple'
Appconf.bootstrap='application.bootstrap'
Appconf.app={}
Appconf.app.root='./'

Appconf.controller={}
Appconf.controller.path=Appconf.app.root .. 'application/controllers/'

Appconf.view={}
Appconf.view.path=Appconf.app.root .. 'application/views/'
Appconf.view.suffix='.html'
Appconf.view.auto_render=true

return Appconf
]]


local errors_conf = [[
-------------------------------------------------------------------------------------------------------------------
-- Define all of your application errors in here. They should have the format:
--
-- local Errors = {
--     [1000] = { status = 500, message = "Controller Err." },
-- }
--
-- where:
--     '1000'                is the error number that can be raised from controllers with `self:raise_error(1000)
--     'status'  (required)  is the http status code
--     'message' (required)  is the error description
-------------------------------------------------------------------------------------------------------------------

local Errors = {}

return Errors
]]

local waf_conf = [[
local waf_conf = {}
waf_conf.ipBlocklist={"1.0.0.1"}
-- waf_conf.html="<!DOCTYPE html><html><body><h1>Fu*k U...</h1><h4>=======</h4><h5>--K--</h5></body></html>"
return waf_conf
]]

local waf_conf_regs_args = [[
\.\./
\:\$
\$\{
select.+(from|limit)
(?:(union(.*?)select))
having|rongjitest
sleep\((\s*)(\d*)(\s*)\)
benchmark\((.*)\,(.*)\)
base64_decode\(
(?:from\W+information_schema\W)
(?:(?:current_)user|database|schema|connection_id)\s*\(
(?:etc\/\W*passwd)
into(\s+)+(?:dump|out)file\s*
group\s+by.+\(
xwork.MethodAccessor
(?:define|eval|file_get_contents|include|require|require_once|shell_exec|phpinfo|system|passthru|preg_\w+|execute|echo|print|print_r|var_dump|(fp)open|alert|showmodaldialog)\(
xwork\.MethodAccessor
(gopher|doc|php|glob|file|phar|zlib|ftp|ldap|dict|ogg|data)\:\/
java\.lang
\$_(GET|post|cookie|files|session|env|phplib|GLOBALS|SERVER)\[
\<(iframe|script|body|img|layer|div|meta|style|base|object|input)
(onmouseover|onerror|onload)\=
]]

local waf_conf_regs_cookie = [[
\.\./
\:\$
\$\{
select.+(from|limit)
(?:(union(.*?)select))
having|rongjitest
sleep\((\s*)(\d*)(\s*)\)
benchmark\((.*)\,(.*)\)
base64_decode\(
(?:from\W+information_schema\W)
(?:(?:current_)user|database|schema|connection_id)\s*\(
(?:etc\/\W*passwd)
into(\s+)+(?:dump|out)file\s*
group\s+by.+\(
xwork.MethodAccessor
(?:define|eval|file_get_contents|include|require|require_once|shell_exec|phpinfo|system|passthru|preg_\w+|execute|echo|print|print_r|var_dump|(fp)open|alert|showmodaldialog)\(
xwork\.MethodAccessor
(gopher|doc|php|glob|file|phar|zlib|ftp|ldap|dict|ogg|data)\:\/
java\.lang
\$_(GET|post|cookie|files|session|env|phplib|GLOBALS|SERVER)\[
]]

local waf_conf_regs_post = [[
select.+(from|limit)
(?:(union(.*?)select))
having|rongjitest
sleep\((\s*)(\d*)(\s*)\)
benchmark\((.*)\,(.*)\)
base64_decode\(
(?:from\W+information_schema\W)
(?:(?:current_)user|database|schema|connection_id)\s*\(
(?:etc\/\W*passwd)
into(\s+)+(?:dump|out)file\s*
group\s+by.+\(
xwork.MethodAccessor
(?:define|eval|file_get_contents|include|require|require_once|shell_exec|phpinfo|system|passthru|preg_\w+|execute|echo|print|print_r|var_dump|(fp)open|alert|showmodaldialog)\(
xwork\.MethodAccessor
(gopher|doc|php|glob|file|phar|zlib|ftp|ldap|dict|ogg|data)\:\/
java\.lang
\$_(GET|post|cookie|files|session|env|phplib|GLOBALS|SERVER)\[
\<(iframe|script|body|img|layer|div|meta|style|base|object|input)
(onmouseover|onerror|onload)\=
]]

local waf_conf_regs_url = [[
\.(svn|htaccess|bash_history)
\.(bak|inc|old|mdb|sql|backup|java|class)$
(vhost|bbs|host|wwwroot|www|site|root|hytop|flashfxp).*\.rar
(phpmyadmin|jmx-console|jmxinvokerservlet)
java\.lang
/(attachments|upimg|images|css|uploadfiles|html|uploads|templets|static|template|data|inc|forumdata|upload|includes|cache|avatar)/(\\w+).(php|jsp)
]]

local waf_conf_regs_ua = [[
(HTTrack|harvest|audit|dirbuster|pangolin|nmap|sqln|-scan|hydra|Parser|libwww|BBBike|sqlmap|w3af|owasp|Nikto|fimap|havij|PycURL|zmeu|BabyKrokodil|netsparker|httperf|bench| SF/)
]]

local waf_conf_regs_whiteurl = [[
^/123/$
]]


local nginx_config_tpl = [[
pid ]] .. va_conf.app_dirs.tmp .. [[/{{VA_ENV}}-nginx.pid;

# This number should be at maxium the number of CPU on the server
worker_processes 4;

events {
    # Number of connections per worker
    worker_connections 4096;
}

http {
    # use sendfile
    sendfile on;

    # Va initialization
    {{LUA_PACKAGE_PATH}}
    {{LUA_PACKAGE_CPATH}}
    {{LUA_CODE_CACHE}}
    {{LUA_SHARED_DICT}}
    {{INIT_BY_LUA}}
    {{INIT_BY_LUA_FILE}}
    {{VANILLA_WAF}}
    {{ACCESS_BY_LUA}}
    {{ACCESS_BY_LUA_FILE}}

    server {
        # List port
        listen {{PORT}};
        set $template_root '';

        # Access log with buffer, or disable it completetely if unneeded
        access_log ]] .. va_conf.app_dirs.logs .. [[/{{VA_ENV}}-access.log combined buffer=16k;
        # access_log off;

        # Error log
        error_log ]] .. va_conf.app_dirs.logs .. [[/{{VA_ENV}}-error.log;

        # Va runtime
        {{CONTENT_BY_LUA_FILE}}
    }
}
]]


local nginx_conf = [[
local ngx_conf = {}

ngx_conf.common = {
    INIT_BY_LUA = 'nginx.init',
    CONTENT_BY_LUA_FILE = './pub/index.lua'
}

ngx_conf.env = {}
ngx_conf.env.development = {
    LUA_CODE_CACHE = false,
    PORT = 7200
}

ngx_conf.env.test = {
    LUA_CODE_CACHE = true,
    PORT = 7201
}

ngx_conf.env.production = {
    LUA_CODE_CACHE = true,
    PORT = 80
}

return ngx_conf
]]

local nginx_init_by_lua_tpl = [[
return function ( ... )
    ngx.zhou = 'jing'
end
]]

local vanilla_index = [[
local config = require('config.application')
local app = require('vanilla.v.application'):new(config)
app:bootstrap():run()
]]


local env_settings = [[
--------------------------------------------------------------------------------
-- Settings defined here are environment dependent. Inside of your application,
-- `va_conf.settings` will return the ones that correspond to the environment
-- you are running the server in.
--------------------------------------------------------------------------------

local Settings = {}

Settings.development = {
    code_cache = false,
    port = 7200,
    expose_api_console = true
}

Settings.test = {
    code_cache = true,
    port = 7201,
    expose_api_console = false
}

Settings.production = {
    code_cache = true,
    port = 80,
    expose_api_console = false
}

return Settings
]]


local index_controller_spec = [[
require 'spec.spec_helper'

describe("PagesController", function()

    describe("#root", function()
        it("responds with a welcome message", function()
            local response = hit({
                method = 'GET',
                path = "/"
            })

            assert.are.same(200, response.status)
            assert.are.same({ message = "Hello world from Va!" }, response.body)
        end)
    end)
end)
]]


local spec_helper = [[
require 'vanilla.spec.runner'
]]


local VaApplication = {}

VaApplication.files = {
    ['.gitignore'] = gitignore,
    ['application/controllers/index.lua'] = index_controller,
    ['application/controllers/error.lua'] = error_controller,
    ['application/library/.gitkeep'] = "",
    ['application/models/dao/table.lua'] = dao,
    ['application/models/service/user.lua'] = service,
    ['application/plugins/.gitkeep'] = "",
    ['application/views/index/index.html'] = index_tpl,
    ['application/views/error/error.html'] = error_tpl,
    ['application/bootstrap.lua'] = bootstrap,
    ['application/nginx/init.lua'] = nginx_init_by_lua_tpl,
    ['config/errors.lua'] = errors_conf,
    ['config/nginx.conf'] = nginx_config_tpl,
    ['config/nginx.lua'] = nginx_conf,
    ['config/waf.lua'] = waf_conf,
    ['config/waf-regs/args'] = waf_conf_regs_args,
    ['config/waf-regs/cookie'] = waf_conf_regs_cookie,
    ['config/waf-regs/post'] = waf_conf_regs_post,
    ['config/waf-regs/url'] = waf_conf_regs_url,
    ['config/waf-regs/user-agent'] = waf_conf_regs_ua,
    ['config/waf-regs/whiteurl'] = waf_conf_regs_whiteurl,
    ['logs/hack/.gitkeep'] = "",
    ['pub/index.lua'] = vanilla_index,
    ['spec/controllers/index_controller_spec.lua'] = index_controller_spec,
    ['spec/models/.gitkeep'] = "",
    ['spec/spec_helper.lua'] = spec_helper
}

function VaApplication.new(name)
    print(ansicolors("Creating app %{green}" .. name .. "%{reset}..."))

    VaApplication.files['config/application.lua'] = string.gsub(application_conf, "{{APP_NAME}}", name)
    VaApplication.create_files(name)
end

function VaApplication.create_files(parent)
    for file_path, file_content in pairs(VaApplication.files) do
        -- ensure containing directory exists
        local full_file_path = parent .. "/" .. file_path
        helpers.mkdirs(full_file_path)

        -- create file
        local fw = io.open(full_file_path, "w")
        fw:write(file_content)
        fw:close()
        print(ansicolors("  %{green}created file%{reset} " .. full_file_path))
    end
end

return VaApplication
