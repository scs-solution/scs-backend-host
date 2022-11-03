from flask import Flask, request, jsonify
import os
import asyncio

app = Flask(__name__)


async def applyInfraInternal(params):
    os.system(
        f'./script/apply-infra.sh "{params["privateKey"]}" "{params["desc"]}" "{params["updateKey"]}"'
    )


async def handleSpotTerminationInternal(params):
    os.system(
        f'./script/handle-spot-instance.sh "{params["target"]}" "{params["privateKey"]}" "{params["desc"]}" "{params["updateKey"]}"'
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
    loop = asyncio.get_event_loop()
    loop.create_task(applyInfraInternal(params))
    return jsonify({"ok": True})


@app.route('/handle-spot-termination', methods=['POST'])
def handleSpotTermination():
    params = request.get_json()
    loop = asyncio.get_event_loop()
    loop.create_task(handleSpotTerminationInternal(params))
    return jsonify({"ok": True})


if __name__ == "__main__":
    app.run()
