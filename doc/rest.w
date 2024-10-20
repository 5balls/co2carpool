% Copyright 2022,2023,2024 Florian Pesth
%
% This file is part of co2carpool.
%
% co2carpool is free software: you can redistribute it and/or modify
% it under the terms of the GNU Affero General Public License as
% published by the Free Software Foundation version 3 of the
% License.
%
% co2carpool is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU Affero General Public License for more details.
%
% You should have received a copy of the GNU Affero General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

\subsection{rest class}

The rest class uses libcurl to send rest requests to graphhopper.

\begin{lstlisting}
apt-get install libcurl4 libcurl4-openssl-dev nlohmann-json3-dev
\end{lstlisting}

@O ../src/rest.h -d
@{
#ifndef REST_CLASS
#define REST_CLASS

#include <iostream>
#include <map>
#include <string>

#include <curl/curl.h>
# define JSON_DIAGNOSTICS 1
#include <nlohmann/json.hpp>

class rest{
public:
    rest(const nlohmann::json& config);
    ~rest(void);
    nlohmann::json post(const std::string& url_ref, const char* options);
    nlohmann::json get(const std::string& url_ref, std::vector<std::pair<std::string, std::string> > options);
private:
    CURL* curl;
    CURLcode result;
    struct curl_slist *headers;
    struct cfg {
        std::map<std::string, std::string> urls;
    } config;
    NLOHMANN_DEFINE_TYPE_INTRUSIVE(cfg, urls);
};

#endif
@}

@O ../src/rest.cpp -d
@{

#include "rest.h"
#include <fstream>

rest::rest(const nlohmann::json& l_config):
    headers(NULL), config(l_config)
{
    std::cout << "Initializing CURL...";
    curl_global_init(CURL_GLOBAL_ALL);
    curl = curl_easy_init();
    if(!curl){
        std::cout << " failed!\n";
    }
    std::cout << " ok!\n";
    std::cout << "Set headers to json...";
    headers = curl_slist_append(headers, "Accept: application/json");  
    headers = curl_slist_append(headers, "Content-Type: application/json");
    headers = curl_slist_append(headers, "charset: utf-8"); 
    result = curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
    if(result != CURLE_OK){
        std::cout << " failed, error by curl is \"" << curl_easy_strerror(result) << "\"\n";
        return;
    }
    std::cout << " ok!\n";
}

rest::~rest(void){
    std::cout << "Cleaning up CURL...\n";
    curl_easy_cleanup(curl);
    curl_global_cleanup();
}

size_t writeIntoStdString(void* ptr, size_t size, size_t nmemb, void* str) {
    std::string* stdString = static_cast<std::string*>(str);
    stdString->erase(std::find(stdString->begin(), stdString->end(), '\0'), stdString->end());
    stdString->erase(std::find(stdString->begin(), stdString->end(), '\r'), stdString->end());
    std::copy((char*)ptr, (char*)ptr + (size + nmemb), std::back_inserter(*stdString));
    return size * nmemb;
}

nlohmann::json rest::post(const std::string& url_ref, const char* options){
    std::cout << "Send post request...";
    //curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);
    //curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, 0L);
    //curl_easy_setopt(curl, CURLOPT_URL, "http://localhost:8989");
    result = curl_easy_setopt(curl, CURLOPT_URL, config.urls[url_ref].c_str());
    if(result != CURLE_OK)
        std::cout << "Error in curl_easy_setopt for CURLOPT_URL = \"" << config.urls[url_ref].c_str() << "\" error by curl is \"" << curl_easy_strerror(result) << "\"\n";
    result = curl_easy_setopt(curl, CURLOPT_POSTFIELDS, options);
    if(result != CURLE_OK)
        std::cout << "Error in curl_easy_setopt for CURLOPT_POSTFIELDS = \"" << options << "\" error by curl is \"" << curl_easy_strerror(result) << "\"\n";
    result = curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, writeIntoStdString); 
    if(result != CURLE_OK)
        std::cout << "Error in curl_easy_setopt for CURLOPT_WRITEFUNCTION = \"" << writeIntoStdString << "\" error by curl is \"" << curl_easy_strerror(result) << "\"\n";
    std::string resultString;
    result = curl_easy_setopt(curl, CURLOPT_WRITEDATA, &resultString);
    if(result != CURLE_OK)
        std::cout << "Error in curl_easy_setopt for CURLOPT_WRITEDATA = \"" << &resultString << "\" error by curl is \"" << curl_easy_strerror(result) << "\"\n";
    result = curl_easy_perform(curl);
    if(result != CURLE_OK)
        std::cout << "Error in post request for url \"" << config.urls[url_ref].c_str() << "\", options \"" << options << "\", error by curl is \"" << curl_easy_strerror(result) << "\"\n";
    nlohmann::json resultJson = nlohmann::json::parse(resultString);
    std::cout << " ok!\n";
    return resultJson;
}

nlohmann::json rest::get(const std::string& url_ref, std::vector<std::pair<std::string, std::string> > options){
    const char* l_url = config.urls[url_ref].c_str();
    curl_easy_setopt(curl, CURLOPT_HTTPGET, 1L);
    CURLU *url = curl_url();
    curl_url_set(url, CURLUPART_URL, l_url, 0);
    for(const auto& option: options)
        curl_url_set(url, CURLUPART_QUERY, (option.first + "=" + option.second).c_str(), CURLU_APPENDQUERY);
    curl_easy_setopt(curl, CURLOPT_CURLU, url);
    //curl_easy_setopt(curl, CURLOPT_GETFIELDS, options);
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, writeIntoStdString); 
    std::string resultString;
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, &resultString);
    result = curl_easy_perform(curl);
    if(result != CURLE_OK)
        std::cout << "Error in get request for url \"" << url << "\", error by curl is \"" << curl_easy_strerror(result) << "\"\n";
    nlohmann::json resultJson;
    try{
        resultJson = nlohmann::json::parse(resultString);
    } catch(...){
        std::cout << "Could not parse json\n";
    }
    return resultJson;
}


@}

