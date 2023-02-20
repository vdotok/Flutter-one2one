package com.cloudwebrtc.webrtc.callsdks.utils

import android.annotation.TargetApi
import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioPlaybackCaptureConfiguration
import android.media.AudioRecord
import android.media.projection.MediaProjection
import android.os.Build
import android.util.Log
import androidx.annotation.RequiresApi
import java.nio.ByteBuffer

// we will create max 2 audio recorder one for internal audio
// other one is for mic audio upon need

fun createMicRecorder(
    audioSource: Int,
    sampleRate: Int,
    channelConfig: Int,
    audioFormat: Int
): AudioRecord {
    val bytesPerFrame: Int = audioFormat * getBytesPerSample(2)
    val framesPerBuffer = sampleRate / 100
    val byteBuffer = ByteBuffer.allocateDirect(bytesPerFrame * framesPerBuffer)
    val minBufferSize = AudioRecord.getMinBufferSize(sampleRate, channelConfig, audioFormat)
    val bufferSizeInBytes: Int = Math.max(2 * minBufferSize, byteBuffer.capacity())

    return if (Build.VERSION.SDK_INT >= 23) {
        createAudioRecordOnMOrHigher(
            audioSource,
            sampleRate,
            channelConfig,
            audioFormat,
            bufferSizeInBytes
        )
    } else {
        createAudioRecordOnLowerThanM(
            audioSource,
            sampleRate,
            channelConfig,
            audioFormat,
            bufferSizeInBytes
        )
    }
}

private fun getBytesPerSample(audioFormat: Int): Int {
    return when (audioFormat) {
        0, 5, 6, 7, 8, 9, 10, 11, 12 -> throw java.lang.IllegalArgumentException("Bad audio format $audioFormat")
        1, 2, 13 -> 2
        3 -> 1
        4 -> 4
        else -> throw java.lang.IllegalArgumentException("Bad audio format $audioFormat")
    }
}


@TargetApi(29)
fun createAppAudioRecorder(mediaProjection: MediaProjection, sampleRate: Int): AudioRecord {
    val config = AudioPlaybackCaptureConfiguration.Builder(mediaProjection)
        .addMatchingUsage(AudioAttributes.USAGE_MEDIA).build()
    return AudioRecord.Builder().setAudioPlaybackCaptureConfig(config).setAudioFormat(
        AudioFormat.Builder().setEncoding(AudioFormat.ENCODING_DEFAULT).setSampleRate(sampleRate)
            .setChannelMask(AudioFormat.CHANNEL_IN_STEREO).build()
    ).build()
}

//@TargetApi(23)
@RequiresApi(Build.VERSION_CODES.M)
private fun createAudioRecordOnMOrHigher(
    audioSource: Int,
    sampleRate: Int,
    channelConfig: Int,
    audioFormat: Int,
    bufferSizeInBytes: Int
): AudioRecord {
    Log.d("CreateMicRecorder", "createAudioRecordOnMOrHigher")
    return AudioRecord.Builder().setAudioSource(audioSource).setAudioFormat(
        AudioFormat.Builder().setEncoding(audioFormat).setSampleRate(sampleRate)
            .setChannelMask(channelConfig).build()

    ).setBufferSizeInBytes(bufferSizeInBytes).build()
}

private fun createAudioRecordOnLowerThanM(
    audioSource: Int,
    sampleRate: Int,
    channelConfig: Int,
    audioFormat: Int,
    bufferSizeInBytes: Int
): AudioRecord {
    Log.d("CreateMicRecorder", "createAudioRecordOnLowerThanM")
    return AudioRecord(audioSource, sampleRate, channelConfig, audioFormat, bufferSizeInBytes)
}
