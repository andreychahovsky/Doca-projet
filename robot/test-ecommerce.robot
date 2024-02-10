*** Settings ***
Library    SeleniumLibrary
Test Setup    Open Browser    https://www.google.com/    chrome
Test Teardown    Close Browser

*** Variables ***
${BROWSER}    chrome
${BASE_URL}    https://www.google.com/
${create_acc_url}    http://127.0.0.1:5000/register
${login_url}    http://127.0.0.1:5000/login
${logout_url}    http://127.0.0.1:5000/logout
${username}    Vasia
${email}    vasia@pupkin.com
${password}    Password-1


*** Test Cases ***
E-Commerce
    Maximize Browser Window
    Set Selenium Implicit Wait    10 seconds
    # Create Account    ${username}    ${email}    ${password}
    Login    ${username}    ${password}
    Logout

*** Keywords ***

Create Account
    [Arguments]    ${username}    ${email}    ${password}
    Go To    ${create_acc_url}
    Sleep    2 seconds
    Input Text    id=username    ${username}
    Input Text    id=email_address    ${email}
    Input Text    id=password1    ${password}
    Input Text    id=password2    ${password}
    Click Button    id=submit

Login
    [Arguments]    ${username}    ${password}
    Go To    ${login_url}
    Sleep    2 seconds
    Input Text    id=username    ${username}
    Input Text    id=password    ${password}
    Click Button    id=submit

Logout
    Go To    ${logout_url}
    Sleep    5 seconds
    ${page_title}    Get Title
    Should Be Equal As Strings    first=${page_title}    second=E-Commerce    msg="Actual page title is '${page_title}'.\n Expected page title is 'E-Commerce'."