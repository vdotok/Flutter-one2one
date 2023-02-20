package com.cloudwebrtc.webrtc


import android.app.Activity
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.media.projection.MediaProjection
import com.cloudwebrtc.webrtc.callsdks.utils.*
import org.webrtc.audio.AudioDeviceModule
import org.webrtc.audio.JavaAudioDeviceModule

class createAppRecorder(activity: Activity) {
    var activity: Activity = activity;
    fun createJavaAudioDevice(sMediaProjection: MediaProjection?=null): AudioDeviceModule {

        // Set audio record error callbacks.
        val audioRecordErrorCallback: JavaAudioDeviceModule.AudioRecordErrorCallback = object :
            JavaAudioDeviceModule.AudioRecordErrorCallback {
            override fun onWebRtcAudioRecordInitError(errorMessage: String) {}

            override fun onWebRtcAudioRecordStartError(
                errorCode: JavaAudioDeviceModule.AudioRecordStartErrorCode,
                errorMessage: String
            ) {
            }

            override fun onWebRtcAudioRecordError(errorMessage: String) {}
        }
        val audioTrackErrorCallback: JavaAudioDeviceModule.AudioTrackErrorCallback = object :
            JavaAudioDeviceModule.AudioTrackErrorCallback {
            override fun onWebRtcAudioTrackInitError(errorMessage: String) {}

            override fun onWebRtcAudioTrackStartError(
                errorCode: JavaAudioDeviceModule.AudioTrackStartErrorCode,
                errorMessage: String
            ) {
            }

            override fun onWebRtcAudioTrackError(errorMessage: String) {}
        }
//        val AUDIO_SOURCE_MIC = MediaRecorder.AudioSource.VOICE_COMMUNICATION
//        val AUDIO_SOURCE_APP_AUDIO = MediaRecorder.AudioSource.REMOTE_SUBMIX
//        val SAMPLE_RATE_IN_HZ = 44100
//        val CHANNEL_CONFIG = AudioFormat.CHANNEL_IN_STEREO
//        val AUDIO_FORMAT = AudioFormat.ENCODING_PCM_16BIT



        return JavaAudioDeviceModule.builder(activity.applicationContext)
            .setUseHardwareAcousticEchoCanceler(false)
            .setUseHardwareNoiseSuppressor(false)
            .setSampleRate(SAMPLE_RATE_IN_HZ)
            .setUseStereoInput(true)
            .setAudioSource(if (sMediaProjection != null) AUDIO_SOURCE_APP_AUDIO else AUDIO_SOURCE_MIC)
            .setAudioFormat(AUDIO_FORMAT)
            .setAudioRecordErrorCallback(audioRecordErrorCallback)
            .setAudioTrackErrorCallback(audioTrackErrorCallback)
            .setAudioRecorder(makeAudioRecorder(mediaProjection = sMediaProjection) )
            .createAudioDeviceModule()
    }


    private fun makeAudioRecorder(mediaProjection: MediaProjection?): AudioRecord {
        mediaProjection?.let {
            return createAppAudioRecorder(mediaProjection, SAMPLE_RATE_IN_HZ )
        }?: kotlin.run {
            return createMicRecorder(
                AUDIO_SOURCE_MIC, SAMPLE_RATE_IN_HZ,
                CHANNEL_CONFIG, AUDIO_FORMAT
            )
        }
    }

}