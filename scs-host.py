from flask import Flask, request, jsonify
import os

app = Flask(__name__)


@app.route('/create-ssh-keypair', methods=['POST'])
def createSSHKeypair():
    params = request.get_json()
    os.system(
        f'./script/create-ssh-keypair.sh "{params["userId"]}" "{params["fn"]}" "{params["url"]}"')
    return jsonify({"ok": True})


if __name__ == "__main__":
    app.run()
