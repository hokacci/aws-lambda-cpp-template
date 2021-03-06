#include <aws/lambda-runtime/runtime.h>

#include <iostream>

using namespace aws::lambda_runtime;


static invocation_response my_handler(invocation_request const& req) {
    std::cout << "Function invoked. req: " << req.payload << std::endl;

    return invocation_response::success("{\"OK\": true}", "application/json");
}



int main() {
    std::cout << "Starting Lambda" << std::endl;

    run_handler(my_handler);

    return 0;
}
