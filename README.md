# aws-lambda-rust-test

Serverless API code that uses an AWS Lambda function with an API gateway. The project code is at https://github.com/pauleaster/aws-lambda-rust-test. Thanks to the following two youtube videos (https://www.youtube.com/watch?v=wlVcso4Ut5o and  https://www.youtube.com/watch?v=PmtwtK6jyLc), with the help of the following docs (lambda_http, lambda_runtime, and terraform), I was able to get a serverless REST query up in a couple of days.

# Usage
This project is meant to be modified by you depending on how you want to use the data. At the moment the query keys and values are only returned in the response. The headers are disabled for privacy reasons. Setting `USE_HEADERS` to `Headers::Use` will enable the headers in the response. 

To test this code run:
```
curl "https://xxw2x1h890.execute-api.ap-southeast-2.amazonaws.com/?key1=data1&key2=data2&key3=data3"
```
or paste the following into your browser:
```
https://xxw2x1h890.execute-api.ap-southeast-2.amazonaws.com/?key1=data1&key2=data2&key3=data3
```

The response you should get is (though not necessarily in this order):
```
{
    "key2": "data2",
    "key1": "data1",
    "key3": "data3",
}
```
# How it works
When you execute the `curl` command, enter the url in your browser, or send a `POST` to this url, the AWS API Gateway funnels your request through to the rust lambda system where it launches the rust code and returns the result. 

# Why rust????
The rust programming language is fast and secure. The compiler works to try to eliminate as many errors as possible at compile time. For beginning rust programmers this can be somewhat frustrating, but after writing enough projects, one can greatly appreciate the reduction in errors during the compile process. The surprising thing is that often, once you get your program to compile, it works first time as expected. This is not something that I have experienced with either python or C. 

From a speed point of view, in a serverless environment, I would point you to https://filia-aleks.medium.com/aws-lambda-battle-2021-performance-comparison-for-all-languages-c1b441005fd1. Here, `rust` and `Go` are leading in both the cold and warm start up times for serverless execution time when compared against NodeJs, Python, Ruby, .Net, Java, GraalVM (noting that there are a few merge requests waiting that are designed to speed up the rust, .Net, and NodeJS codes).