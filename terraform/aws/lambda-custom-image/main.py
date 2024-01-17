import base64
import bcrypt
import os

PASSWORD_HASH = str.encode(os.environ.get('PASSWORD_HASH', ""))


# https://stackoverflow.com/questions/3405073/generating-dictionary-keys-on-the-fly/3405143#3405143
class D(dict):
    def __missing__(self, key):
        self[key] = D()
        return self[key]


def lambda_handler(event, context):
    # print("event="+json.dumps(event))
    event = D(event)    # make it safe to dereference

    mqtt_username = event['protocolData']['mqtt']['username'] or ""
    mqtt_client_id = event['protocolData']['mqtt']['clientId'] or ""

    print(f"MQTT Username: {mqtt_username}")
    print(f"MQTT Client ID: {mqtt_client_id}")

    # Data in the password field is base64-encoded by AWS IoT Core. Your Lambda function must decode it.
    mqtt_password_base64 = event['protocolData']['mqtt']['password'] or ""
    try:
        mqtt_password = base64.b64decode(mqtt_password_base64).decode('utf-8')
    except UnicodeDecodeError as e:
        print("Error")
        return generateAuthResponse(mqtt_client_id, 'Deny')

    mqtt_password_byte = str.encode(mqtt_password)

    if (PASSWORD_HASH) and bcrypt.checkpw(mqtt_password_byte, PASSWORD_HASH):
        print("Allow")
        return generateAuthResponse(mqtt_client_id, 'Allow')
    else:
        print("Deny")
        return generateAuthResponse(mqtt_client_id, 'Deny')


def generateAuthResponse(token, effect):
    auth_response = {
        'isAuthenticated': True,
        'principalId': 'Tasmota',
        'disconnectAfterInSeconds': 86400,
        'refreshAfterInSeconds': 86400,
        'policyDocuments': [{
            'Version': '2012-10-17',
            'Statement': [{
                'Action': [
                    'iot:Connect',
                    'iot:Publish',
                    'iot:Subscribe',
                    'iot:Receive',
                ],
                'Effect': effect,
                'Resource': '*'
            }]
        }]
    }
    return auth_response
