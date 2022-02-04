final Map<String, dynamic> TEST_TYPED_DATA = {
  "domain": {
    "name": "BountiableTokenTester",
    "version": "1",
    "chainId": 31337,
    "verifyingContract": "0x7A9Ec1d04904907De0ED7b6839CcdD59c3716AC9",
  },
  "primaryType": 'Bounty',
  "types": {
    "EIP712Domain": [
      {"name": 'name', "type": 'string'},
      {"name": 'version', "type": 'string'},
      {"name": 'chainId', "type": 'uint256'},
      {"name": 'verifyingContract', "type": 'address'},
    ],
    "Bounty": [
      {"name": "target", "type": "address"},
      {"name": "data", "type": "bytes"},
      {"name": "reward", "type": "uint256"},
      {"name": "nonce", "type": "uint256"},
      {"name": "deadline", "type": "uint256"},
    ],
  },
  "message": {
    "target": "0x7A9Ec1d04904907De0ED7b6839CcdD59c3716AC9",
    "data": "0x713d3e3e",
    "reward": 50,
    "nonce": 0,
    "deadline": 1624373141,
  },
};
final Map<String, dynamic> TEST_TYPED_DATAWithoutEipDomain = {
  "domain": {
    "name": "BountiableTokenTester",
    "version": "1",
    "chainId": 31337,
    "verifyingContract": "0x7A9Ec1d04904907De0ED7b6839CcdD59c3716AC9",
  },
  "primaryType": 'Bounty',
  "types": {
    "Bounty": [
      {"name": "target", "type": "address"},
      {"name": "data", "type": "bytes"},
      {"name": "reward", "type": "uint256"},
      {"name": "nonce", "type": "uint256"},
      {"name": "deadline", "type": "uint256"},
    ],
  },
  "message": {
    "target": "0x7A9Ec1d04904907De0ED7b6839CcdD59c3716AC9",
    "data": "0x713d3e3e",
    "reward": 50,
    "nonce": 0,
    "deadline": 1624373141,
  },
};
final TEST_TYPES = {
  "EIP712Domain": [
    {"name": 'name', "type": 'string'},
    {"name": 'version', "type": 'string'},
    {"name": 'chainId', "type": 'uint256'},
    {"name": 'verifyingContract', "type": 'address'},
  ],
  "Bounty": [
    {"name": "target", "type": "address"},
    {"name": "data", "type": "bytes"},
    {"name": "reward", "type": "uint256"},
    {"name": "nonce", "type": "uint256"},
    {"name": "deadline", "type": "uint256"},
  ],
};
final Map<String, dynamic> TEST_TYPED_DATA_2 = {
  "domain": {
    // Defining the chain aka Rinkeby testnet or Ethereum Main Net
    "chainId": 1,
    // Give a user friendly name to the specific contract you are signing for.
    "name": 'Ether Mail',
    // If name isn't enough add verifying contract to make sure you are establishing contracts with the proper entity
    "verifyingContract": '0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC',
    // Just let's you know the latest version. Definitely make sure the field name is correct.
    "version": '1',
  },

  // Defining the message signing data content.
  "message": {
    /*
     - Anything you want. Just a JSON Blob that encodes the data you want to send
     - No required fields
     - This is DApp Specific
     - Be as explicit as possible when building out the message schema.
    */
    "contents": 'Hello, Bob!',
    "from": {
      "name": 'Cow',
      "wallets": [
        '0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826',
        '0xDeaDbeefdEAdbeefdEadbEEFdeadbeEFdEaDbeeF',
      ],
    },
    "to": [
      {
        "name": 'Bob',
        "wallets": [
          '0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB',
          '0xB0BdaBea57B0BDABeA57b0bdABEA57b0BDabEa57',
          '0xB0B0b0b0b0b0B000000000000000000000000000',
        ],
      },
    ],
  },
  // Refers to the keys of the *types* object below.
  "primaryType": 'Mail',
  "types": {
    // TODO: Clarify if EIP712Domain refers to the domain the contract is hosted on
    "EIP712Domain": [
      {"name": 'name', "type": 'string'},
      {"name": 'version', "type": 'string'},
      {"name": 'chainId', "type": 'uint256'},
      {"name": 'verifyingContract', "type": 'address'},
    ],
    // Not an EIP712Domain definition
    "Group": [
      {"name": 'name', "type": 'string'},
      {"name": 'members', "type": 'Person[]'},
    ],
    // Refer to Primary"Type"
    "Mail": [
      {"name": 'from', "type": 'Person'},
      {"name": 'to', "type": 'Person[]'},
      {"name": 'contents', "type": 'string'},
    ],
    // Not an EIP712Domain definition
    "Person": [
      {"name": 'name', "type": 'string'},
      {"name": 'wallets', "type": 'address[]'},
    ],
  },
};
final Map<String, dynamic> TEST_TYPED_DATA_2_WITHOUT_EIP = {
  "domain": {
    // Defining the chain aka Rinkeby testnet or Ethereum Main Net
    "chainId": 1,
    // Give a user friendly name to the specific contract you are signing for.
    "name": 'Ether Mail',
    // If name isn't enough add verifying contract to make sure you are establishing contracts with the proper entity
    "verifyingContract": '0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC',
    // Just let's you know the latest version. Definitely make sure the field name is correct.
    "version": '1',
  },

  // Defining the message signing data content.
  "message": {
    /*
     - Anything you want. Just a JSON Blob that encodes the data you want to send
     - No required fields
     - This is DApp Specific
     - Be as explicit as possible when building out the message schema.
    */
    "contents": 'Hello, Bob!',
    "from": {
      "name": 'Cow',
      "wallets": [
        '0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826',
        '0xDeaDbeefdEAdbeefdEadbEEFdeadbeEFdEaDbeeF',
      ],
    },
    "to": [
      {
        "name": 'Bob',
        "wallets": [
          '0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB',
          '0xB0BdaBea57B0BDABeA57b0bdABEA57b0BDabEa57',
          '0xB0B0b0b0b0b0B000000000000000000000000000',
        ],
      },
    ],
  },
  // Refers to the keys of the *types* object below.
  "primaryType": 'Mail',
  "types": {
    // TODO: Clarify if EIP712Domain refers to the domain the contract is hosted on

    // Not an EIP712Domain definition
    "Group": [
      {"name": 'name', "type": 'string'},
      {"name": 'members', "type": 'Person[]'},
    ],
    // Refer to Primary"Type"
    "Mail": [
      {"name": 'from', "type": 'Person'},
      {"name": 'to', "type": 'Person[]'},
      {"name": 'contents', "type": 'string'},
    ],
    // Not an EIP712Domain definition
    "Person": [
      {"name": 'name', "type": 'string'},
      {"name": 'wallets', "type": 'address[]'},
    ],
  },
};
final SANITIZED_TYPED_DATA = {
  "types": {
    "EIP712Domain": [
      {
        "name": "name",
        "type": "string",
      },
      {
        "name": "version",
        "type": "string",
      },
      {
        "name": "chainId",
        "type": "uint256",
      },
      {
        "name": "verifyingContract",
        "type": "address",
      },
    ],
    "Bounty": [
      {
        "name": "target",
        "type": "address",
      },
      {
        "name": "data",
        "type": "bytes",
      },
      {
        "name": "reward",
        "type": "uint256",
      },
      {
        "name": "nonce",
        "type": "uint256",
      },
      {
        "name": "deadline",
        "type": "uint256",
      },
    ],
  },
  "primaryType": "Bounty",
  "domain": {
    "name": "BountiableTokenTester",
    "version": "1",
    "chainId": 31337,
    "verifyingContract": "0x7A9Ec1d04904907De0ED7b6839CcdD59c3716AC9",
  },
  "message": {
    "target": "0x7A9Ec1d04904907De0ED7b6839CcdD59c3716AC9",
    "data": "0x713d3e3e",
    "reward": 50,
    "nonce": 0,
    "deadline": 1624373141,
  },
};
final SANITIZED_TYPED_DATA_WITHOUT_EIP = {
  "types": {
    "EIP712Domain": [],
    "Bounty": [
      {
        "name": "target",
        "type": "address",
      },
      {
        "name": "data",
        "type": "bytes",
      },
      {
        "name": "reward",
        "type": "uint256",
      },
      {
        "name": "nonce",
        "type": "uint256",
      },
      {
        "name": "deadline",
        "type": "uint256",
      },
    ],
  },
  "primaryType": "Bounty",
  "domain": {
    "name": "BountiableTokenTester",
    "version": "1",
    "chainId": 31337,
    "verifyingContract": "0x7A9Ec1d04904907De0ED7b6839CcdD59c3716AC9",
  },
  "message": {
    "target": "0x7A9Ec1d04904907De0ED7b6839CcdD59c3716AC9",
    "data": "0x713d3e3e",
    "reward": 50,
    "nonce": 0,
    "deadline": 1624373141,
  },
};
final SANITIZED_TYPED_DATA2 = {
  "types": {
    "EIP712Domain": [
      {
        "name": "name",
        "type": "string",
      },
      {
        "name": "version",
        "type": "string",
      },
      {
        "name": "chainId",
        "type": "uint256",
      },
      {
        "name": "verifyingContract",
        "type": "address",
      },
    ],
    "Group": [
      {
        "name": "name",
        "type": "string",
      },
      {
        "name": "members",
        "type": "Person[]",
      },
    ],
    "Mail": [
      {
        "name": "from",
        "type": "Person",
      },
      {
        "name": "to",
        "type": "Person[]",
      },
      {
        "name": "contents",
        "type": "string",
      },
    ],
    "Person": [
      {
        "name": "name",
        "type": "string",
      },
      {
        "name": "wallets",
        "type": "address[]",
      },
    ],
  },
  "primaryType": "Mail",
  "domain": {
    "chainId": 1,
    "name": "Ether Mail",
    "verifyingContract": "0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC",
    "version": "1",
  },
  "message": {
    "contents": "Hello, Bob!",
    "from": {
      "name": "Cow",
      "wallets": [
        "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826",
        "0xDeaDbeefdEAdbeefdEadbEEFdeadbeEFdEaDbeeF",
      ],
    },
    "to": [
      {
        "name": "Bob",
        "wallets": [
          "0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB",
          "0xB0BdaBea57B0BDABeA57b0bdABEA57b0BDabEa57",
          "0xB0B0b0b0b0b0B000000000000000000000000000",
        ],
      },
    ],
  },
};
final SANITIZED_TYPED_DATA2_WITHOUT_EIP = {
  "types": {
    "EIP712Domain": [],
    "Group": [
      {
        "name": "name",
        "type": "string",
      },
      {
        "name": "members",
        "type": "Person[]",
      },
    ],
    "Mail": [
      {
        "name": "from",
        "type": "Person",
      },
      {
        "name": "to",
        "type": "Person[]",
      },
      {
        "name": "contents",
        "type": "string",
      },
    ],
    "Person": [
      {
        "name": "name",
        "type": "string",
      },
      {
        "name": "wallets",
        "type": "address[]",
      },
    ],
  },
  "primaryType": "Mail",
  "domain": {
    "chainId": 1,
    "name": "Ether Mail",
    "verifyingContract": "0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC",
    "version": "1",
  },
  "message": {
    "contents": "Hello, Bob!",
    "from": {
      "name": "Cow",
      "wallets": [
        "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826",
        "0xDeaDbeefdEAdbeefdEadbEEFdeadbeEFdEaDbeeF",
      ],
    },
    "to": [
      {
        "name": "Bob",
        "wallets": [
          "0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB",
          "0xB0BdaBea57B0BDABeA57b0bdABEA57b0BDabEa57",
          "0xB0B0b0b0b0b0B000000000000000000000000000",
        ],
      },
    ],
  },
};
final TEST_TYPES_2 = {
  // TODO: Clarify if EIP712Domain refers to the domain the contract is hosted on
  "EIP712Domain": [
    {"name": 'name', "type": 'string'},
    {"name": 'version', "type": 'string'},
    {"name": 'chainId', "type": 'uint256'},
    {"name": 'verifyingContract', "type": 'address'},
  ],
  // Not an EIP712Domain definition
  "Group": [
    {"name": 'name', "type": 'string'},
    {"name": 'members', "type": 'Person[]'},
  ],
  // Refer to Primary"Type"
  "Mail": [
    {"name": 'from', "type": 'Person'},
    {"name": 'to', "type": 'Person[]'},
    {"name": 'contents', "type": 'string'},
  ],
  // Not an EIP712Domain definition
  "Person": [
    {"name": 'name', "type": 'string'},
    {"name": 'wallets', "type": 'address[]'},
  ],
};
final TEST_TYPED_DATA_3 = {
  "domain": {
    "name": "ChequableTokenTester",
    "version": "1",
    "chainId": 31337,
    "verifyingContract": "0x07882Ae1ecB7429a84f1D53048d35c4bB2056877",
  },
  "primaryType": 'Cheque',
  "types": {
    "EIP712Domain": [
      {"name": 'name', "type": 'string'},
      {"name": 'version', "type": 'string'},
      {"name": 'chainId', "type": 'uint256'},
      {"name": 'verifyingContract', "type": 'address'},
    ],
    "Cheque": [
      {"name": "spender", "type": "address"},
      {"name": "amount", "type": "uint256"},
      {"name": "nonce", "type": "uint256"},
      {"name": "deadline", "type": "uint256"},
    ],
  },
  "message": {
    "spender": "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC",
    "amount": 50,
    "nonce": 0,
    "deadline": 1624372302,
  },
};
//
final TEST_TYPED_DATA_4 = {
  "domain": {
    "name": "ChequableTokenTester",
    "version": "1",
    "chainId": 31337,
    "verifyingContract": "0x34B40BA116d5Dec75548a9e9A8f15411461E8c70",
  },
  "primaryType": 'Cheque',
  "types": {
    "EIP712Domain": [
      {"name": 'name', "type": 'string'},
      {"name": 'version', "type": 'string'},
      {"name": 'chainId', "type": 'uint256'},
      {"name": 'verifyingContract', "type": 'address'}
    ],
    "Cheque": [
      {"name": "spender", "type": "address"},
      {"name": "amount", "type": "uint256"},
      {"name": "nonce", "type": "uint256"},
      {"name": "deadline", "type": "uint256"},
    ],
  },
  "message": {
    "spender": "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC",
    "amount": 50,
    "nonce": 0,
    "deadline": 1624372301,
  },
};
