## AWS User Group Florianópolis
### Creating Lambda functions schedules using Terraform modules

File structure:
```
.github/
    workflows/
        ...(actions related files to deploy the resources on AWS using Terraform)
infrastructure/
    lambdas/
        ebs-checker/
            ...(related Terraform files)
        resizing-service/
            ...(related Terraform files)
    modules/
        complete/
            ...(calls the following modules: lambda_function, eventbridge_schedule and sns_topic modules)
        lambda-function/
            ...(module to create lambda_functions)
        eventbridge-schedule/
            ...(module to create an eventbridge_schedule)
lambdas/
        ebs-checker/
            lambda_function.py
        resizing-service/
            lambda_function.py
```