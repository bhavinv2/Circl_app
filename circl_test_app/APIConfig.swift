#if targetEnvironment(simulator)
let baseURL = "http://127.0.0.1:8000/api/"   // simulator local
#else
let baseURL = "https://circlapp.online/api/"   // real device PRODUCTION
#endif
