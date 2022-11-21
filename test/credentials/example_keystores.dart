const content = '''
{
  "test1": {
    "json": {
      "crypto" : {
        "cipher" : "aes-128-ctr",
        "cipherparams" : {
          "iv" : "6087dab2f9fdbbfaddc31a909735c1e6"
        },
        "ciphertext" : "5318b4d5bcd28de64ee5559e671353e16f075ecae9f99c7a79a38af5f869aa46",
        "kdf" : "pbkdf2",
        "kdfparams" : {
          "c" : 262144,
          "dklen" : 32,
          "prf" : "hmac-sha256",
          "salt" : "ae3cd4e7013836a3df6bd7241b12db061dbe2c6785853cce422d148a624ce0bd"
        },
        "mac" : "fb132cf2e0ab51ff37571e45011c37daf12383bfa93e2fc4744b4d7e9493c39a"
      },
      "id" : "3198bc9c-6672-5ab3-d995-4942343ae5b6",
      "version" : 3
    },
    "password": "testpassword",
    "priv": "7a28b5ba57c53603b0b07b56bba752f7784bf506fa95edc395f5cf6c7514fe9d"
  },
  "test2": {
    "json": {
      "crypto" : {
        "cipher" : "aes-128-ctr",
        "cipherparams" : {
          "iv" : "83dbcc02d8ccb40e466191a123791e0e"
        },
        "ciphertext" : "d172bf743a674da9cdad04534d56926ef8358534d458fffccd4e6ad2fbde479c",
        "kdf" : "scrypt",
        "kdfparams" : {
          "dklen" : 32,
          "n" : 262144,
          "r" : 1,
          "p" : 8,
          "salt" : "ab0c7876052600dd703518d6fc3fe8984592145b591fc8fb5c6d43190334ba19"
        },
        "mac" : "8afa141f3a677e33435e34b0eaa5a846454c8487c189d28dca2fe376eb0bb364"
      },
      "id" : "3198bc9c-6672-5ab3-d995-4942343ae5b6",
      "version" : 3
    },
    "password": "testpassword",
    "priv": "7a28b5ba57c53603b0b07b56bba752f7784bf506fa95edc395f5cf6c7514fe9d"
  },
  "python_generated_test_with_odd_iv": {
    "json": {
      "version": 3,
      "crypto": {
        "ciphertext": "ee75456c006b1e468133c5d2a916bacd3cf515ced4d9b021b5c59978007d1e87",
        "version": 1,
        "kdf": "pbkdf2",
        "kdfparams": {
          "dklen": 32,
          "c": 262144,
          "prf": "hmac-sha256",
          "salt": "504490577620f64f43d73f29479c2cf0"
        },
        "mac": "ec5b64aaacc05fa541909e34463c170c7bcd434f9f599cae76a85ab51a5973cd",
        "cipherparams": {
          "iv": "514ccc8c4fb3e60e5538e0cf1e27c233"
        },
        "cipher": "aes-128-ctr"
      },
      "id": "98d193c7-5174-4c7c-5345-c1daf95477b5"
    },
    "password": "foo",
    "priv": "0101010101010101010101010101010101010101010101010101010101010101"
  },
  "evilnonce": {
    "json": {
      "version": 3,
      "crypto": {
        "ciphertext": "d69313b6470ac1942f75d72ebf8818a0d484ac78478a132ee081cd954d6bd7a9",
        "cipherparams": {
          "iv": "ffffffffffffffffffffffffffffffff"
        },
        "kdf": "pbkdf2",
        "kdfparams": {
          "dklen": 32,
          "c": 262144,
          "prf": "hmac-sha256",
          "salt": "c82ef14476014cbf438081a42709e2ed"
        },
        "mac": "fe87a2fa4db5a3d0215731e9220fd06abd0b418782cc716e598d1bd7b4502f47",
        "cipher": "aes-128-ctr",
        "version": 1
      },
      "id": "abb67040-8dbe-0dad-fc39-2b082ef0ee5f"
    },
    "password": "bar",
    "priv": "0202020202020202020202020202020202020202020202020202020202020202"
  }
}
''';
