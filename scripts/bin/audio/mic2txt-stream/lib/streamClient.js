// streamClient.js - WebSocket client for Deepgram streaming transcription

import WebSocket from "ws";
import fs from "fs";

// Listen to the incoming piped audio
let audioBuffer = [];
process.stdin.on("data", onStdinData);
process.stdin.on("end", onStdinEnd);

// Connecting to WebSocket Deepgram API
const apiKey = process.env.DEEPGRAM_API_KEY;
const config = {
  language: "fr",
  encoding: "linear16",
  sample_rate: 16000,
  interim_results: true,
  model: "nova-2-general",
  punctuate: true,
  smart_format: true,
  paragraphs: true,
};
const url = `wss://api.deepgram.com/v1/listen?` + new URLSearchParams(config);
const ws = new WebSocket(url, {
  headers: {
    Authorization: `Token ${apiKey}`,
  },
});
ws.on("open", onWebSocketOpen);
ws.on("message", onWebSocketMessage);
ws.on("close", onWebSocketClose);

const keepAlive = createKeepAlive(ws);
const transcripts = [];
const outputDir = "/dev/shm/oroshi/mic2txt/deepgram";
const outputFile = `${outputDir}/transcript.txt`;
fs.mkdirSync(outputDir, { recursive: true });

// Event handler functions
function onStdinData(chunk) {
  // If websocket not yet opened, we keep in memory
  if (ws.readyState !== WebSocket.OPEN) {
    audioBuffer.push(chunk);
    return;
  }

  // We send it
  ws.send(chunk);
}

function onStdinEnd() {
  ws.send(JSON.stringify({ type: "CloseStream" }));
}

function onWebSocketOpen() {
  keepAlive.start();

  // Send buffered audio data
  audioBuffer.forEach((chunk) => ws.send(chunk));
  audioBuffer = [];
}

function onWebSocketMessage(data) {
  const response = JSON.parse(data.toString());
  const transcript = response.channel?.alternatives?.[0]?.transcript;

  // Early return if not a final transcript
  if (!transcript || response.type !== "Results" || !response.is_final) {
    return;
  }

  transcripts.push(transcript);
}

function onWebSocketClose() {
  keepAlive.stop();

  // Write all transcripts to file
  const finalText = transcripts.join(" ");
  fs.writeFileSync(outputFile, finalText, "utf8");

  process.exit(0);
}

function createKeepAlive(ws) {
  let interval;
  const message = JSON.stringify({ type: "KeepAlive" });

  return {
    start() {
      interval = setInterval(() => {
        ws.send(message);
      }, 5000);
    },

    stop() {
      clearInterval(interval);
    },
  };
}
