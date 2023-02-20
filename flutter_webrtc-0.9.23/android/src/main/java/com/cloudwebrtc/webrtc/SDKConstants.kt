package com.cloudwebrtc.webrtc;

import android.media.AudioFormat
import android.media.MediaRecorder

const val STREAM_HOST = "wss://kurento1.togee.io:8443/call"
const val AUDIO_SOURCE_MIC = MediaRecorder.AudioSource.VOICE_COMMUNICATION
const val AUDIO_SOURCE_APP_AUDIO = MediaRecorder.AudioSource.REMOTE_SUBMIX
const val SAMPLE_RATE_IN_HZ = 44100
const val CHANNEL_CONFIG = AudioFormat.CHANNEL_IN_STEREO
const val AUDIO_FORMAT = AudioFormat.ENCODING_PCM_16BIT

const val PUBLIC_IP_URL: String = "http://whatismyip.akamai.com/"
val PUBLIC_URL_ARRAY = arrayListOf("http://whatismyip.akamai.com/",
    "https://wgetip.com",
    "https://eth0.me")

//    API ERROR LOG TAGS
const val API_ERROR = "API_ERROR"
const val HTTP_CODE_NO_NETWORK = 600
const val SUCCESS_CODE = 200