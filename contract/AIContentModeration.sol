// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./IAIOracle.sol"; 
import "./AIOracleCallbackReceiver.sol"; 

contract AIContentModeration is AIOracleCallbackReceiver {
    uint64 public constant AIORACLE_CALLBACK_GAS_LIMIT = 5000000;
    // Event emitted when content evaluation is updated by the zkOracle
    event ContentEvaluated(uint256 requestId, bool isExplicit);

    // Event emitted when a new content request is made
    event ContentRequested(uint256 requestId, address requester);

    // Event emitted when content is received from the AI Oracle
    event ContentReceived(uint256 requestId, string content, bool isExplicit);

    // Structure to hold details of content requests
    struct ContentRequest {
        address requester; // Address of the user requesting content
        uint256 modelId; // ID of the AI model used for generating content
        string prompt; // Prompt sent to the AI Oracle
        bool evaluated; // Flag to indicate if the content has been evaluated by the zkOracle
        bool isExplicit; // Flag to indicate if the content contains explicit material
    }

    // Mapping from request IDs to content requests
    mapping(uint256 => ContentRequest) public requests;

    // Counter to generate unique request IDs
    uint256 public nextRequestId = 1;

    // Constructor binds the contract to a specific AI Oracle
    constructor(IAIOracle _aiOracle) AIOracleCallbackReceiver(_aiOracle) {}

// Function to request content generation from the AI Oracle
function requestContent(string memory prompt, uint256 modelId) external payable {
    bytes memory input = bytes(prompt); // Convert the prompt to bytes

    // Send the content generation request to the AI Oracle and capture the returned requestId
    uint256 requestId = aiOracle.requestCallback{value: msg.value}(modelId, input, address(this), AIORACLE_CALLBACK_GAS_LIMIT, "");

    // Store the request details in the mapping using the AI Oracle-generated requestId
    requests[requestId] = ContentRequest({
        requester: msg.sender,
        modelId: modelId,
        prompt: prompt,
        evaluated: false, // Initially set to false indicating the content is not yet evaluated
        isExplicit: false // Initially set to false as the content has not been checked yet
    });

    // Emit an event indicating a new content request has been made
    emit ContentRequested(requestId, msg.sender);
}


    // Callback function called by the AI Oracle when content is generated
    function aiOracleCallback(uint256 requestId, bytes calldata output, bytes calldata callbackData) external override onlyAIOracleCallback() {
        // Ensure the request exists
        require(requests[requestId].requester != address(0), "Request not found");

        // Mark the content as received and ready for off-chain evaluation
        requests[requestId].evaluated = false; // Set to false indicating it's not yet evaluated

        // Emit an event with the received content (not yet marked as explicit or not)
        emit ContentReceived(requestId, string(output), requests[requestId].isExplicit);
    }

    // Function to be called by the zkOracle to update content evaluation
    function updateContentEvaluation(uint256 requestId, bool isExplicit) external {
        // TODO: Add access control to ensure only the zkOracle can call this function

        // Ensure the request exists and is ready for evaluation
        require(requests[requestId].requester != address(0), "Request not found");
        require(!requests[requestId].evaluated, "Content already evaluated");

        // Update the request with the evaluation result
        requests[requestId].evaluated = true; // Mark as evaluated
        requests[requestId].isExplicit = isExplicit; // Set the explicit flag based on the zkOracle's evaluation

        // Emit an event indicating the content has been evaluated for explicit material
        emit ContentEvaluated(requestId, isExplicit);
    }
}


