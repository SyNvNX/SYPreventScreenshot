/*
 Copyright (c) 2012-2019, Pierre-Olivier Latour
 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 * The name of Pierre-Olivier Latour may not be used to endorse
 or promote products derived from this software without specific
 prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL PIERRE-OLIVIER LATOUR BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

// http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
// http://www.iana.org/assignments/http-status-codes/http-status-codes.xhtml

#import <Foundation/Foundation.h>

/**
 *  Convenience constants for "informational" HTTP status codes.
 */
typedef NS_ENUM(NSInteger, SYWebServerInformationalHTTPStatusCode) {
    kSYWebServerHTTPStatusCode_Continue = 100,
    kSYWebServerHTTPStatusCode_SwitchingProtocols = 101,
    kSYWebServerHTTPStatusCode_Processing = 102
};

/**
 *  Convenience constants for "successful" HTTP status codes.
 */
typedef NS_ENUM(NSInteger, SYWebServerSuccessfulHTTPStatusCode) {
    kSYWebServerHTTPStatusCode_OK = 200,
    kSYWebServerHTTPStatusCode_Created = 201,
    kSYWebServerHTTPStatusCode_Accepted = 202,
    kSYWebServerHTTPStatusCode_NonAuthoritativeInformation = 203,
    kSYWebServerHTTPStatusCode_NoContent = 204,
    kSYWebServerHTTPStatusCode_ResetContent = 205,
    kSYWebServerHTTPStatusCode_PartialContent = 206,
    kSYWebServerHTTPStatusCode_MultiStatus = 207,
    kSYWebServerHTTPStatusCode_AlreadyReported = 208
};

/**
 *  Convenience constants for "redirection" HTTP status codes.
 */
typedef NS_ENUM(NSInteger, SYWebServerRedirectionHTTPStatusCode) {
    kSYWebServerHTTPStatusCode_MultipleChoices = 300,
    kSYWebServerHTTPStatusCode_MovedPermanently = 301,
    kSYWebServerHTTPStatusCode_Found = 302,
    kSYWebServerHTTPStatusCode_SeeOther = 303,
    kSYWebServerHTTPStatusCode_NotModified = 304,
    kSYWebServerHTTPStatusCode_UseProxy = 305,
    kSYWebServerHTTPStatusCode_TemporaryRedirect = 307,
    kSYWebServerHTTPStatusCode_PermanentRedirect = 308
};

/**
 *  Convenience constants for "client error" HTTP status codes.
 */
typedef NS_ENUM(NSInteger, SYWebServerClientErrorHTTPStatusCode) {
    kSYWebServerHTTPStatusCode_BadRequest = 400,
    kSYWebServerHTTPStatusCode_Unauthorized = 401,
    kSYWebServerHTTPStatusCode_PaymentRequired = 402,
    kSYWebServerHTTPStatusCode_Forbidden = 403,
    kSYWebServerHTTPStatusCode_NotFound = 404,
    kSYWebServerHTTPStatusCode_MethodNotAllowed = 405,
    kSYWebServerHTTPStatusCode_NotAcceptable = 406,
    kSYWebServerHTTPStatusCode_ProxyAuthenticationRequired = 407,
    kSYWebServerHTTPStatusCode_RequestTimeout = 408,
    kSYWebServerHTTPStatusCode_Conflict = 409,
    kSYWebServerHTTPStatusCode_Gone = 410,
    kSYWebServerHTTPStatusCode_LengthRequired = 411,
    kSYWebServerHTTPStatusCode_PreconditionFailed = 412,
    kSYWebServerHTTPStatusCode_RequestEntityTooLarge = 413,
    kSYWebServerHTTPStatusCode_RequestURITooLong = 414,
    kSYWebServerHTTPStatusCode_UnsupportedMediaType = 415,
    kSYWebServerHTTPStatusCode_RequestedRangeNotSatisfiable = 416,
    kSYWebServerHTTPStatusCode_ExpectationFailed = 417,
    kSYWebServerHTTPStatusCode_UnprocessableEntity = 422,
    kSYWebServerHTTPStatusCode_Locked = 423,
    kSYWebServerHTTPStatusCode_FailedDependency = 424,
    kSYWebServerHTTPStatusCode_UpgradeRequired = 426,
    kSYWebServerHTTPStatusCode_PreconditionRequired = 428,
    kSYWebServerHTTPStatusCode_TooManyRequests = 429,
    kSYWebServerHTTPStatusCode_RequestHeaderFieldsTooLarge = 431
};

/**
 *  Convenience constants for "server error" HTTP status codes.
 */
typedef NS_ENUM(NSInteger, SYWebServerServerErrorHTTPStatusCode) {
    kSYWebServerHTTPStatusCode_InternalServerError = 500,
    kSYWebServerHTTPStatusCode_NotImplemented = 501,
    kSYWebServerHTTPStatusCode_BadGateway = 502,
    kSYWebServerHTTPStatusCode_ServiceUnavailable = 503,
    kSYWebServerHTTPStatusCode_GatewayTimeout = 504,
    kSYWebServerHTTPStatusCode_HTTPVersionNotSupported = 505,
    kSYWebServerHTTPStatusCode_InsufficientStorage = 507,
    kSYWebServerHTTPStatusCode_LoopDetected = 508,
    kSYWebServerHTTPStatusCode_NotExtended = 510,
    kSYWebServerHTTPStatusCode_NetworkAuthenticationRequired = 511
};
