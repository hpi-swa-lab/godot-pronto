const REDIRECT_CLIENT_PORT = 39714
const REDIRECT_CLIENT_BINDING = "127.0.0.1"

# Local settings
# const BACKEND_SCHEME = "http"
# const BACKEND_DOMAIN = "127.0.0.1:42000"

# Remote settings
const BACKEND_SCHEME = "https"
const BACKEND_DOMAIN = "www.hpi.uni-potsdam.de/hirschfeld/prompto"

const BACKEND_BASE_URL = BACKEND_SCHEME + "://" + BACKEND_DOMAIN

const BACKEND_API = {
	LOGIN_URL = BACKEND_BASE_URL + "/auth/login",
	LOGIN_SUCCESS_URL = BACKEND_BASE_URL + "/auth/success",
	LOGOUT_URL = BACKEND_BASE_URL + "/auth/logout",
	WHOAMI_URL = BACKEND_BASE_URL + "/auth/whoami",
	CREATE_CHAT_URL = BACKEND_BASE_URL + "/chat/create",
	CONTINUE_CHAT_URL = BACKEND_BASE_URL + "/chat/continue",
	FEEDBACK_URL = BACKEND_BASE_URL + "/chat/feedback"
}
