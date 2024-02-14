*** Settings ***
Library    SeleniumLibrary
Library    String
Test Setup    Open Browser    https://www.google.com/    chrome
Test Teardown    Close Browser

*** Variables ***
${BROWSER}    chrome
${BASE_URL}    https://www.google.com/
${create_acc_url}    http://127.0.0.1:5000/register
${login_url}    http://127.0.0.1:5000/login
${logout_url}    http://127.0.0.1:5000/logout
${market_url}    http://127.0.0.1:5000/market
${username}    Vasia
${email}    vasia@pupkin.com
${password}    Password-1
${password_incorrect}    password-1

*** Test Cases ***
E-Commerce
    Maximize Browser Window
    Set Selenium Implicit Wait    5 seconds
    # Create Account    ${username}    ${email}    ${password}
    Login    ${username}    ${password}
    # User Profile
    Check Details
    Check Buy
    Check Sell
    Check Balance
    Check List Owned
    Logout
    Login incorrect    ${username}    ${password_incorrect}

*** Keywords ***

Create Account
    [Arguments]    ${username}    ${email}    ${password}
    Go To    ${create_acc_url}
    Sleep    1 seconds
    Input Text    id=username    ${username}
    Input Text    id=email_address    ${email}
    Input Text    id=password1    ${password}
    Input Text    id=password2    ${password}
    Click Button    id=submit

Login
    [Arguments]    ${username}    ${password}
    Go To    ${login_url}
    Sleep    1 seconds
    Input Text    id=username    ${username}
    Input Text    id=password    ${password}
    Click Button    id=submit

User Profile
    Click Element    xpath://b[contains(text(),'${username}')]
    ${page_title}    Get Title
    Should Not Be Equal As Strings    first=${page_title}    second=E-Commerce | Market    msg=Actual result : The same page\nExpected result : User Profile page

Check Details
    Go To    ${market_url}
    Sleep    1 seconds
    Click Button    xpath://button[contains(text(),'Info')]
    Page Should Contain Element    xpath://div[contains(@class,'modal-dialog')]    message=Actual result : There is no element with the class 'modal-dialog'.\nEcpected result : There is an modal window with the class 'modal-dialog'.
    Click Button    xpath://button[contains(text(),'Close')]

Check Buy
    Go to    ${market_url}
    Sleep    1 seconds
    ${owned_items}    Get Element Count    xpath://div[contains(@class,'card-body')]
    Should Be Equal As Numbers    first=${owned_items}    second=0    msg=Before buy:\nActual count of items is ${owned_items}.\nExpected cont of items is 0.
    ${available_items_before_buy}    Get Element Count    xpath://tr
    ${available_items_before_buy}    Convert To Number    ${available_items_before_buy}
    Click Button    xpath://button[contains(text(),'Buy')]
    Wait Until Element Is Visible    id=submit
    Click Element    id=submit
    ${owned_items}    Get Element Count    xpath://div[contains(@class,'card-body')]
    Should Be Equal As Numbers    first=${owned_items}    second=1    msg=After buy:\nActual count of items is ${owned_items}.\nExpected cont of items is 1.
    ${available_items_after_buy}    Get Element Count    xpath://tr
    ${available_items_after_buy}    Convert To Number    ${available_items_after_buy}
    ${check_items}    Evaluate    ${available_items_before_buy} - 1
    Should Be Equal As Numbers    first=${available_items_after_buy}    second=${check_items}    msg=Available items after buy ERROR.

Check Sell
    Go to    ${market_url}
    Sleep    1 seconds
    ${owned_items}    Get Element Count    xpath://div[contains(@class,'card-body')]
    Should Be Equal As Numbers    first=${owned_items}    second=1    msg=Before sell:\nActual count of items is ${owned_items}.\nExpected cont of items is 1.
    ${available_items_before_sell}    Get Element Count    xpath://tr
    ${available_items_before_sell}    Convert To Number    ${available_items_before_sell}
    Click Button    xpath://button[contains(text(),'Sell')]
    Sleep    1 seconds
    Click Element    xpath://div[@id='Sell-1']/div/div/div[2]/form/div/input[2]
    ${owned_items}    Get Element Count    xpath://div[contains(@class,'card-body')]
    Should Be Equal As Numbers    first=${owned_items}    second=0    msg=After sell:\nActual count of items is ${owned_items}.\nExpected cont of items is 0.
    ${available_items_after_sell}    Get Element Count    xpath://tr
    ${available_items_after_sell}    Convert To Number    ${available_items_after_sell}
    ${check_items}    Evaluate    ${available_items_before_sell} + 1
    Should Be Equal As Numbers    first=${available_items_after_sell}    second=${check_items}    msg=Available items after sell ERROR.

Check Balance
    Go to    ${market_url}
    Sleep    1 seconds
    ${balance_exist}    Run Keyword And Return Status    Page Should Contain Element    xpath://a[contains(@style,'color: lawngreen; font-weight: bold')]
    IF    ${balance_exist} == ${True}
        ${balance_before}    Get Text    xpath://a[contains(@style,'color: lawngreen; font-weight: bold')]
        ${balance_before}    Remove String    ${balance_before}    $    ,
        ${balance_before}    Convert To Integer    ${balance_before}
        ${expected_balance}    Set Variable    ${10000}
        Should Be Equal As Numbers    first=${balance_before}    second=10000    msg=Balance start:\nActual balance is ${balance_before}.\nExpected balance is ${expected_balance}.
        ${price}    Get Text    xpath://tr[1]/td[3]
        ${price}    Remove String    ${price}    $    ,
        ${price}    Convert To Integer    ${price}
        ${expected_balance}    Evaluate    ${balance_before} - ${price}
        Click Button    xpath://button[contains(text(),'Buy')]
        Wait Until Element Is Visible    id=submit
        Click Element    id=submit
        ${balance_after}    Get Text    xpath://a[contains(@style,'color: lawngreen; font-weight: bold')]
        ${balance_after}    Remove String    ${balance_after}    $    ,
        ${balance_after}    Convert To Integer    ${balance_after}
        Should Be Equal As Numbers    first=${balance_after}    second=${expected_balance}    msg=Balance start:\nActual balance is ${balance_after}.\nExpected balance is ${expected_balance}.
        Click Button    xpath://button[contains(text(),'Sell')]
        Sleep    1 seconds
        Click Element    xpath://div[@id='Sell-1']/div/div/div[2]/form/div/input[2]
        ${balance_after}    Get Text    xpath://a[contains(@style,'color: lawngreen; font-weight: bold')]
        ${balance_after}    Remove String    ${balance_after}    $    ,
        ${balance_after}    Convert To Integer    ${balance_after}
        ${expected_balance}    Set Variable    ${10000}
        Should Be Equal As Numbers    first=${balance_after}    second=${expected_balance}    msg=Balance start:\nActual balance is ${balance_after}.\nExpected balance is ${expected_balance}.
    ELSE
        Should Be True    condition=${balance_exist}    msg=There is no balance
    END

Check List Owned
    Go to    ${market_url}
    Sleep    1 seconds
    ${owned_items}    Get Element Count    xpath://div[contains(@class,'card-body')]
    Should Be Equal As Numbers    first=${owned_items}    second=0    msg=Before buy:\nActual count of items is ${owned_items}.\nExpected cont of items is 0.
    Click Button    xpath://button[contains(text(),'Buy')]
    Wait Until Element Is Visible    id=submit
    Click Element    id=submit
    ${owned_items}    Get Element Count    xpath://div[contains(@class,'card-body')]
    Should Be Equal As Numbers    first=${owned_items}    second=1    msg=After buy:\nActual count of items is ${owned_items}.\nExpected cont of items is 1.
    ${owned_items}    Get Element Count    xpath://div[contains(@class,'card-body')]
    Should Be Equal As Numbers    first=${owned_items}    second=1    msg=Before sell:\nActual count of items is ${owned_items}.\nExpected cont of items is 1.
    Click Button    xpath://button[contains(text(),'Sell')]
    Sleep    1 seconds
    Click Element    xpath://div[@id='Sell-1']/div/div/div[2]/form/div/input[2]
    ${owned_items}    Get Element Count    xpath://div[contains(@class,'card-body')]
    Should Be Equal As Numbers    first=${owned_items}    second=0    msg=After sell:\nActual count of items is ${owned_items}.\nExpected cont of items is 0.

Logout
    Go To    ${logout_url}
    Sleep    1 seconds
    ${page_title}    Get Title
    Should Be Equal As Strings    first=${page_title}    second=E-Commerce    msg=Actual page title is '${page_title}'.\nExpected page title is 'E-Commerce'.

Login Incorrect
    [Arguments]    ${username}    ${password_incorrect}
    Go To    ${login_url}
    Sleep    1 seconds
    Input Text    id=username    ${username}
    Input Text    id=password    ${password_incorrect}
    Click Button    id=submit
    ${alert_text}    Get Text    xpath://div[@class='alert alert-danger'][1]
    Should Be Equal As Strings    first=${alert_text}    second=×\nUsername and password are not match! Please try again    msg=Actual alert message : ${alert_text}\nExpected message : ×\nUsername and password are not match! Please try again.