# AI Voice Cloning Integration

Your video-builder now supports real AI voice cloning.

## Supported Engines

| Engine | Quality | Local? | Needs | Best for |
|--------|---------|--------|-------|----------|
| **chatterbox** | Excellent | Yes | GPU ~4GB + 5s reference clip | Production UGC |
| **elevenlabs** | Highest | No | API key | Max quality |
| **espeak** | Robotic | Yes | Nothing | Fallback |

## Quick Setup (Chatterbox - Recommended)

On your VPS / server:

```bash
cd ~/Planlife-agent0-openmanus/video-builder

# Install (needs GPU for best speed)
pip install chatterbox-tts torchaudio

# Put a 5-10 second clean voice sample here
# (your voice or a licensed voice you own rights to)
mkdir -p ~/voices
# copy your reference.wav into ~/voices/myvoice.wav

# Start with voice cloning enabled
export TTS_ENGINE=chatterbox
export VOICE_REF_PATH=~/voices/myvoice.wav
python app.py
```

Or via the stack launcher:

```bash
export TTS_ENGINE=chatterbox
export VOICE_REF_PATH=/home/ubuntu/voices/myvoice.wav
bash start_otto_stack.sh   # or OpenManus/start-native.sh
```

## ElevenLabs (optional paid)

```bash
export TTS_ENGINE=elevenlabs
export ELEVENLABS_API_KEY=sk_xxxx
export ELEVENLABS_VOICE_ID=21m00Tcm4TlvDq8ikWAM   # or your cloned voice ID
```

## Auto Mode

If you set `TTS_ENGINE=auto` (default):
- Uses Chatterbox if installed
- Falls back to espeak if not

## Reference Voice Tips

- 5–15 seconds of clean speech
- No background music / noise
- Single speaker
- WAV or high-quality MP3
- You must own the rights to the voice

## Test

```bash
curl -X POST http://127.0.0.1:8001/build \
  -H 'Content-Type: application/json' \
  -d '{"title":"Test Clone","script":"This is my cloned voice speaking naturally."}'
```

Check the response for `"tts_engine": "chatterbox"`.
