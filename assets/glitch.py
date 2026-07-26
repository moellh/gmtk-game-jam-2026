#!/usr/bin/env python3
import math, random, struct, wave

SR, DUR = 44100, 0.28
N = int(SR * DUR)
random.seed(1337)

out, held = [], 0.0
for i in range(N):
    buzz = 1.0 if math.sin(2 * math.pi * 82 * i / SR) >= 0 else -1.0
    mix = 0.6 * random.uniform(-1, 1) + 0.4 * buzz
    if i % 5 == 0: held = round(mix * 16) / 16
    env = min(1.0, i / (SR * 0.008), (N - i) / (SR * 0.045))
    out.append(held * env)

gain = 10 ** (-17 / 20) / max(abs(v) for v in out)
frames = b"".join(struct.pack("<h", int(max(-1, min(1, v * gain)) * 32767)) for v in out)

with wave.open("glitch.wav", "wb") as w:
    w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
    w.writeframes(frames)
