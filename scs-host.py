from flask import Flask, request, jsonify
import os
import subprocess

app = Flask(__name__)


def applyInfraInternal(params):
    subprocess.Popen(
        [f'./script/apply-infra.sh',
            f'{params["privateKey"]}', f'{params["desc"]}', f'{params["updateKey"]}']
    )


def destroyInfraInternal(params):
    subprocess.Popen(
        [f'./script/destroy-infra.sh',
            f'{params["privateKey"]}', f'{params["desc"]}', f'{params["updateKey"]}']
    )


def initInstanceInternal(params):
    subprocess.Popen(
        [f"./script/init-instance.sh",
            f'{params["instance"]}', f'{params["privateKey"]}', f'{params["updateKey"]}']
    )


def handleSpotTerminationInternal(params):
    subprocess.Popen(
        [f'./script/handle-spot-instance.sh',
            f'{params["instanceId"]}', f'{params["privateKey"]}', f'{params["instanceType"]}', f'{params["amiId"]}', f'{params["updateKey"]}']
    )


def createAMIInternal(params):
    subprocess.Popen(
        [f'./script/create-ami.sh',
         f'{params["instanceId"]}', f'{params["latestAMI"]}', f'{params["updateKey"]}']
    )


@app.route('/create-ssh-keypair', methods=['POST'])
def createSSHKeypair():
    params = request.get_json()
    os.system(
        f'./script/create-ssh-keypair.sh "{params["userId"]}" "{params["fn"]}" "{params["url"]}"')
    return jsonify({"ok": True})


@app.route('/apply-infra', methods=['POST'])
def applyInfra():
    params = request.get_json()
    applyInfraInternal(params)
    return jsonify({"ok": True})


@app.route('/destroy-infra', methods=['POST'])
def destroyInfra():
    params = request.get_json()
    destroyInfraInternal(params)
    return jsonify({"ok": True})


@app.route('/init-instance', methods=['POST'])
def initInstance():
    params = request.get_json()
    initInstanceInternal(params)
    return jsonify({"ok": True})


@app.route('/handle-spot-termination', methods=['POST'])
def handleSpotTermination():
    params = request.get_json()
    handleSpotTerminationInternal(params)
    return jsonify({"ok": True})


@app.route('/create-ami', methods=['POST'])
def createAMI():
    params = request.get_json()
    createAMIInternal(params)
    return jsonify({"ok": True})


if __name__ == "__main__":
    app.run()
