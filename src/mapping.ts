//@ts-ignore
import { Bytes, Block, Event } from "@hyperoracle/zkgraph-lib";

// Assuming this is the event signature for "ContentReceived(uint256,string,bool)" event.
const CONTENT_RECEIVED_EVENT_SIG = Bytes.fromHexString("0xa8fdeeb873a64442f9d27aae4182a0139b065b43b19cac2dc293941750530139");

// This function will be triggered for every block and will process the relevant events.
export function handleBlocks(blocks: Block[]): Bytes {
    for (let event of blocks[0].events) {
        // Filter events for the "ContentReceived" event using its signature
        if (event.esig.equals(CONTENT_RECEIVED_EVENT_SIG)) {
            
            //  requestId occupies the first 32 bytes of the event data
            const requestIdBytes = event.data.slice(0, 32);
            const contentHex = event.data.slice(64); //  content starts after requestId and a potential 32-byte offset

            // Convert hex content to string for moderation check
            const contentString = hexToString(contentHex);

            // Check for explicit content
            const isExplicit = checkContentForExplicitness(contentString);

            // Prepare the function call to "updateContentEvaluation"
            const isExplicitFlag = isExplicit ? Bytes.fromHexString("0x0000000000000000000000000000000000000000000000000000000000000001")
                                              : Bytes.fromHexString("0x0000000000000000000000000000000000000000000000000000000000000000");

            // Function signature for "updateContentEvaluation(uint256,bool)"
            let functionSignature = Bytes.fromHexString("90dbcf62");

            // Concatenate the function signature with parameters to form the calldata
            let calldata = functionSignature.concat(requestIdBytes).concat(isExplicitFlag);

            return calldata;
        }
    }
    return Bytes.empty(); // Return empty if no relevant events are found
}

// Converts hexadecimal string (without 0x prefix) to a readable string
function hexToString(hexStr: Bytes): string {
    var hex = hexStr.toHexString().replace(/^0x/, '');
    var str = '';
    for (var i = 0; i < hex.length; i += 2) {
        var v = parseInt(hex.substr(i, 2), 16);
        if (v) str += String.fromCharCode(v);
    }
    return str;
}

// Custom function to check if a string contains a specific substring
function stringIncludes(str: string, search: string): boolean {
  return str.indexOf(search) !== -1;
}

// Adjusted checkContentForExplicitness function to use the custom stringIncludes function
function checkContentForExplicitness(content: string): boolean {
  const explicitPattern = "badword"; // Placeholder for an explicit pattern
  return stringIncludes(content, explicitPattern); // Use the custom function instead of includes
}

