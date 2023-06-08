package com.hiennv.flutter_callkit_incoming

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.graphics.Bitmap
import android.graphics.Color
import android.graphics.drawable.Drawable
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.text.TextUtils
import android.util.Log
import android.view.View
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.hiennv.flutter_callkit_incoming.CallkitIncomingActivity.Companion.ACTION_ENDED_CALL_INCOMING
import com.hiennv.flutter_callkit_incoming.CallkitIncomingBroadcastReceiver.Companion.EXTRA_CALLKIT_ACTION_COLOR
import com.hiennv.flutter_callkit_incoming.CallkitIncomingBroadcastReceiver.Companion.EXTRA_CALLKIT_AVATAR
import com.hiennv.flutter_callkit_incoming.CallkitIncomingBroadcastReceiver.Companion.EXTRA_CALLKIT_DURATION
import com.hiennv.flutter_callkit_incoming.CallkitIncomingBroadcastReceiver.Companion.EXTRA_CALLKIT_HANDLE
import com.hiennv.flutter_callkit_incoming.CallkitIncomingBroadcastReceiver.Companion.EXTRA_CALLKIT_ID
import com.hiennv.flutter_callkit_incoming.CallkitIncomingBroadcastReceiver.Companion.EXTRA_CALLKIT_INCOMING_CALL_NOTIFICATION_CHANNEL_NAME
import com.hiennv.flutter_callkit_incoming.CallkitIncomingBroadcastReceiver.Companion.EXTRA_CALLKIT_IS_CUSTOM_NOTIFICATION
import com.hiennv.flutter_callkit_incoming.CallkitIncomingBroadcastReceiver.Companion.EXTRA_CALLKIT_IS_CUSTOM_SMALL_EX_NOTIFICATION
import com.hiennv.flutter_callkit_incoming.CallkitIncomingBroadcastReceiver.Companion.EXTRA_CALLKIT_MISSED_CALL_NOTIFICATION_CHANNEL_NAME
import com.hiennv.flutter_callkit_incoming.CallkitIncomingBroadcastReceiver.Companion.EXTRA_CALLKIT_NAME_CALLER
import com.hiennv.flutter_callkit_incoming.CallkitIncomingBroadcastReceiver.Companion.EXTRA_CALLKIT_TEXT_ACCEPT
import com.hiennv.flutter_callkit_incoming.CallkitIncomingBroadcastReceiver.Companion.EXTRA_CALLKIT_TEXT_CALLBACK
import com.hiennv.flutter_callkit_incoming.CallkitIncomingBroadcastReceiver.Companion.EXTRA_CALLKIT_TEXT_DECLINE
import com.hiennv.flutter_callkit_incoming.CallkitIncomingBroadcastReceiver.Companion.EXTRA_CALLKIT_TEXT_MISSED_CALL
import com.hiennv.flutter_callkit_incoming.CallkitIncomingBroadcastReceiver.Companion.EXTRA_CALLKIT_TYPE
import com.hiennv.flutter_callkit_incoming.widgets.CircleTransform
import com.squareup.picasso.OkHttp3Downloader
import com.squareup.picasso.Picasso
import com.squareup.picasso.Target
import okhttp3.OkHttpClient


class CallkitNotificationManager(private val context: Context) {

    companion object {

        const val EXTRA_TIME_START_CALL = "EXTRA_TIME_START_CALL"

        private const val NOTIFICATION_CHANNEL_ID_INCOMING = "callkit_incoming_channel_id"
        private const val NOTIFICATION_CHANNEL_ID_MISSED = "callkit_missed_channel_id"
    }

    private lateinit var notificationBuilder: NotificationCompat.Builder
    private var notificationViews: RemoteViews? = null
    private var notificationSmallViews: RemoteViews? = null
    private var notificationId: Int = 9696

    private var targetLoadAvatarDefault = object : Target {
        override fun onBitmapLoaded(bitmap: Bitmap?, from: Picasso.LoadedFrom?) {
            notificationBuilder.setLargeIcon(bitmap)
            getNotificationManager().notify(notificationId, notificationBuilder.build())
        }

        override fun onBitmapFailed(e: Exception?, errorDrawable: Drawable?) {
        }

        override fun onPrepareLoad(placeHolderDrawable: Drawable?) {
        }
    }

    private var targetLoadAvatarCustomize = object : Target {
        override fun onBitmapLoaded(bitmap: Bitmap?, from: Picasso.LoadedFrom?) {
            notificationViews?.setImageViewBitmap(R.id.ivAvatar, bitmap)
            notificationViews?.setViewVisibility(R.id.ivAvatar, View.VISIBLE)
            notificationSmallViews?.setImageViewBitmap(R.id.ivAvatar, bitmap)
            notificationSmallViews?.setViewVisibility(R.id.ivAvatar, View.VISIBLE)
            getNotificationManager().notify(notificationId, notificationBuilder.build())
        }

        override fun onBitmapFailed(e: Exception?, errorDrawable: Drawable?) {
        }

        override fun onPrepareLoad(placeHolderDrawable: Drawable?) {
        }
    }


    fun showIncomingNotification(data: Bundle) {
        data.putLong(EXTRA_TIME_START_CALL, System.currentTimeMillis())

        notificationId = data.getString(EXTRA_CALLKIT_ID, "callkit_incoming").hashCode()
        createNotificationChanel(
            data.getString(EXTRA_CALLKIT_INCOMING_CALL_NOTIFICATION_CHANNEL_NAME, "Incoming Call"),
            data.getString(EXTRA_CALLKIT_MISSED_CALL_NOTIFICATION_CHANNEL_NAME, "Missed Call"),
        )

        notificationBuilder = NotificationCompat.Builder(context, NOTIFICATION_CHANNEL_ID_INCOMING)
        notificationBuilder.setAutoCancel(false)
        notificationBuilder.setChannelId(NOTIFICATION_CHANNEL_ID_INCOMING)
        notificationBuilder.setDefaults(NotificationCompat.DEFAULT_VIBRATE)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            notificationBuilder.setCategory(NotificationCompat.CATEGORY_CALL)
            notificationBuilder.priority = NotificationCompat.PRIORITY_MAX
        }
        notificationBuilder.setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
        notificationBuilder.setOngoing(true)
        notificationBuilder.setWhen(0)
        notificationBuilder.setTimeoutAfter(data.getLong(EXTRA_CALLKIT_DURATION, 0L))
        notificationBuilder.setOnlyAlertOnce(true)
        notificationBuilder.setSound(null)
        notificationBuilder.setFullScreenIntent(
                getActivityPendingIntent(notificationId, data), true
        )
        notificationBuilder.setContentIntent(getActivityPendingIntent(notificationId, data))
        notificationBuilder.setDeleteIntent(getTimeOutPendingIntent(notificationId, data))
        val typeCall = data.getInt(EXTRA_CALLKIT_TYPE, -1)
        var smallIcon = context.applicationInfo.icon
        if (typeCall > 0) {
            smallIcon = R.drawable.ic_video
        } else {
            if (smallIcon >= 0) {
                smallIcon = R.drawable.ic_accept
            }
        }
        notificationBuilder.setSmallIcon(smallIcon)
        val actionColor = data.getString(EXTRA_CALLKIT_ACTION_COLOR, "#4CAF50")
        try {
            notificationBuilder.color = Color.parseColor(actionColor)
        } catch (error: Exception) {
        }
        notificationBuilder.setChannelId(NOTIFICATION_CHANNEL_ID_INCOMING)
        notificationBuilder.priority = NotificationCompat.PRIORITY_MAX
        val isCustomNotification = data.getBoolean(EXTRA_CALLKIT_IS_CUSTOM_NOTIFICATION, false)
        val isCustomSmallExNotification = data.getBoolean(EXTRA_CALLKIT_IS_CUSTOM_SMALL_EX_NOTIFICATION, false)
        if (isCustomNotification) {
            notificationViews =
                    RemoteViews(context.packageName, R.layout.layout_custom_notification)
            initNotificationViews(notificationViews!!, data)

            if ((Build.MANUFACTURER.equals(
                    "Samsung",
                    ignoreCase = true
                ) && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) || isCustomSmallExNotification
            ) {
                notificationSmallViews =
                        RemoteViews(context.packageName, R.layout.layout_custom_small_ex_notification)
                initNotificationViews(notificationSmallViews!!, data)
            } else {
                notificationSmallViews =
                        RemoteViews(context.packageName, R.layout.layout_custom_small_notification)
                initNotificationViews(notificationSmallViews!!, data)
            }

            notificationBuilder.setStyle(NotificationCompat.DecoratedCustomViewStyle())
            notificationBuilder.setCustomContentView(notificationSmallViews)
            notificationBuilder.setCustomBigContentView(notificationViews)
            notificationBuilder.setCustomHeadsUpContentView(notificationSmallViews)
        } else {
            val avatarUrl = data.getString(EXTRA_CALLKIT_AVATAR, "")
            if (avatarUrl != null && avatarUrl.isNotEmpty()) {
                val headers =
                        data.getSerializable(CallkitIncomingBroadcastReceiver.EXTRA_CALLKIT_HEADERS) as HashMap<String, Any?>
                getPicassoInstance(context, headers).load(avatarUrl)
                        .into(targetLoadAvatarDefault)
            }
            notificationBuilder.setContentTitle(data.getString(EXTRA_CALLKIT_NAME_CALLER, ""))
            notificationBuilder.setContentText(data.getString(EXTRA_CALLKIT_HANDLE, ""))
            val textDecline = data.getString(EXTRA_CALLKIT_TEXT_DECLINE, "")
            val declineAction: NotificationCompat.Action = NotificationCompat.Action.Builder(
                    R.drawable.ic_decline,
                    if (TextUtils.isEmpty(textDecline)) context.getString(R.string.text_decline) else textDecline,
                    getDeclinePendingIntent(notificationId, data)
            ).build()
            notificationBuilder.addAction(declineAction)
            val textAccept = data.getString(EXTRA_CALLKIT_TEXT_ACCEPT, "")
            val acceptAction: NotificationCompat.Action = NotificationCompat.Action.Builder(
                    R.drawable.ic_accept,
                    if (TextUtils.isEmpty(textDecline)) context.getString(R.string.text_accept) else textAccept,
                    getAcceptPendingIntent(notificationId, data)
            ).build()
            notificationBuilder.addAction(acceptAction)
        }
        val notification = notificationBuilder.build()
        notification.flags = Notification.FLAG_INSISTENT
        getNotificationManager().notify(notificationId, notification)
    }

    private fun initNotificationViews(remoteViews: RemoteViews, data: Bundle) {
        remoteViews.setTextViewText(
                R.id.tvNameCaller,
                data.getString(EXTRA_CALLKIT_NAME_CALLER, "")
        )
        var callkitExtra :Map<String, Any>  = data!!["EXTRA_CALLKIT_EXTRA"] as Map<String, Any>
        var callingData : Map<String, Any> = callkitExtra.get("callingData") as Map<String, Any>
        var callKitCallType : Boolean = callingData.get("isVideo") as Boolean
        Log.d("thisi is callType", callKitCallType.toString())

        if(callKitCallType){
            remoteViews.setTextViewText(
                R.id.tvCallType, "VIDEO CALL"
//            data.getString(EXTRA_CALLKIT_TYPE, "")
            )
        }else {
            remoteViews.setTextViewText(
                R.id.tvCallType, "AUDIO CALL"
//            data.getString(EXTRA_CALLKIT_TYPE, "")
            )
        }

        remoteViews.setTextViewText(
                R.id.tvNumber,
                data.getString(EXTRA_CALLKIT_HANDLE, "")
        )
        remoteViews.setOnClickPendingIntent(
                R.id.llDecline,
                getDeclinePendingIntent(notificationId, data)
        )
        val textDecline = data.getString(EXTRA_CALLKIT_TEXT_DECLINE, "")
        remoteViews.setTextViewText(
                R.id.tvDecline,
                if (TextUtils.isEmpty(textDecline)) context.getString(R.string.text_decline) else textDecline
        )
        remoteViews.setOnClickPendingIntent(
                R.id.llAccept,
                getAcceptPendingIntent(notificationId, data)
        )
        val textAccept = data.getString(EXTRA_CALLKIT_TEXT_ACCEPT, "")
        remoteViews.setTextViewText(
                R.id.tvAccept,
                if (TextUtils.isEmpty(textAccept)) context.getString(R.string.text_accept) else textAccept
        )
        val avatarUrl = data.getString(EXTRA_CALLKIT_AVATAR, "")
        if (avatarUrl != null && avatarUrl.isNotEmpty()) {
            val headers =
                    data.getSerializable(CallkitIncomingBroadcastReceiver.EXTRA_CALLKIT_HEADERS) as HashMap<String, Any?>
            getPicassoInstance(context, headers).load(avatarUrl)
                    .transform(CircleTransform())
                    .into(targetLoadAvatarCustomize)
        }
    }

    fun showMissCallNotification(data: Bundle) {
        notificationId = data.getString(EXTRA_CALLKIT_ID, "callkit_incoming").hashCode() + 1
        createNotificationChanel(
            data.getString(EXTRA_CALLKIT_INCOMING_CALL_NOTIFICATION_CHANNEL_NAME, "Incoming Call"),
            data.getString(EXTRA_CALLKIT_MISSED_CALL_NOTIFICATION_CHANNEL_NAME, "Missed Call"),
        )
        val missedCallSound: Uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
        val typeCall = data.getInt(EXTRA_CALLKIT_TYPE, -1)
        var smallIcon = context.applicationInfo.icon
        if (typeCall > 0) {
            smallIcon = R.drawable.ic_video_missed
        } else {
            if (smallIcon >= 0) {
                smallIcon = R.drawable.ic_call_missed
            }
        }
        notificationBuilder = NotificationCompat.Builder(context, NOTIFICATION_CHANNEL_ID_MISSED)
        notificationBuilder.setChannelId(NOTIFICATION_CHANNEL_ID_MISSED)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                notificationBuilder.setCategory(Notification.CATEGORY_MISSED_CALL)
            }
        }
        val textMissedCall = data.getString(EXTRA_CALLKIT_TEXT_MISSED_CALL, "")
        notificationBuilder.setSubText(if (TextUtils.isEmpty(textMissedCall)) context.getString(R.string.text_missed_call) else textMissedCall)
        notificationBuilder.setSmallIcon(smallIcon)
        val isCustomNotification = data.getBoolean(EXTRA_CALLKIT_IS_CUSTOM_NOTIFICATION, false)
        if (isCustomNotification) {
            notificationViews =
                    RemoteViews(context.packageName, R.layout.layout_custom_miss_notification)
            notificationViews?.setTextViewText(
                    R.id.tvCallType,
                    data.getString(EXTRA_CALLKIT_NAME_CALLER, "")
            )
            notificationViews?.setTextViewText(
                    R.id.tvNumber,
                    data.getString(EXTRA_CALLKIT_HANDLE, "")
            )
            notificationViews?.setOnClickPendingIntent(
                    R.id.llCallback,
                    getCallbackPendingIntent(notificationId, data)
            )
            val isShowCallback = data.getBoolean(CallkitIncomingBroadcastReceiver.EXTRA_CALLKIT_IS_SHOW_CALLBACK, true)
            notificationViews?.setViewVisibility(R.id.llCallback, if (isShowCallback) View.VISIBLE else View.GONE)
            val textCallback = data.getString(EXTRA_CALLKIT_TEXT_CALLBACK, "")
            notificationViews?.setTextViewText(R.id.tvCallback, if (TextUtils.isEmpty(textCallback)) context.getString(R.string.text_call_back) else textCallback)

            val avatarUrl = data.getString(EXTRA_CALLKIT_AVATAR, "")
            if (avatarUrl != null && avatarUrl.isNotEmpty()) {
                val headers =
                        data.getSerializable(CallkitIncomingBroadcastReceiver.EXTRA_CALLKIT_HEADERS) as HashMap<String, Any?>

                getPicassoInstance(context, headers).load(avatarUrl)
                        .transform(CircleTransform()).into(targetLoadAvatarCustomize)
            }
            notificationBuilder.setStyle(NotificationCompat.DecoratedCustomViewStyle())
            notificationBuilder.setCustomContentView(notificationViews)
            notificationBuilder.setCustomBigContentView(notificationViews)
        } else {
            notificationBuilder.setContentTitle(data.getString(EXTRA_CALLKIT_NAME_CALLER, ""))
            notificationBuilder.setContentText(data.getString(EXTRA_CALLKIT_HANDLE, ""))
            val avatarUrl = data.getString(EXTRA_CALLKIT_AVATAR, "")
            if (avatarUrl != null && avatarUrl.isNotEmpty()) {
                val headers =
                        data.getSerializable(CallkitIncomingBroadcastReceiver.EXTRA_CALLKIT_HEADERS) as HashMap<String, Any?>

                getPicassoInstance(context, headers).load(avatarUrl)
                        .into(targetLoadAvatarDefault)
            }
            val isShowCallback = data.getBoolean(CallkitIncomingBroadcastReceiver.EXTRA_CALLKIT_IS_SHOW_CALLBACK, true)
            if (isShowCallback) {
                val textCallback = data.getString(EXTRA_CALLKIT_TEXT_CALLBACK, "")
                val callbackAction: NotificationCompat.Action = NotificationCompat.Action.Builder(
                        R.drawable.ic_accept,
                        if (TextUtils.isEmpty(textCallback)) context.getString(R.string.text_call_back) else textCallback,
                        getCallbackPendingIntent(notificationId, data)
                ).build()
                notificationBuilder.addAction(callbackAction)
            }
        }
        notificationBuilder.priority = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            NotificationManager.IMPORTANCE_HIGH
        } else {
            Notification.PRIORITY_HIGH
        }
        notificationBuilder.setSound(missedCallSound)
        notificationBuilder.setContentIntent(getAppPendingIntent(notificationId, data))
        val actionColor = data.getString(EXTRA_CALLKIT_ACTION_COLOR, "#4CAF50")
        try {
            notificationBuilder.color = Color.parseColor(actionColor)
        } catch (error: Exception) {
        }

        val notification = notificationBuilder.build()
        getNotificationManager().notify(notificationId, notification)
        Handler(Looper.getMainLooper()).postDelayed({
            try {
                getNotificationManager().notify(notificationId, notification)
            } catch (error: Exception) {
            }
        }, 1000)
    }


    fun clearIncomingNotification(data: Bundle) {
        context.sendBroadcast(CallkitIncomingActivity.getIntentEnded(context))
        notificationId = data.getString(EXTRA_CALLKIT_ID, "callkit_incoming").hashCode()
        getNotificationManager().cancel(notificationId)
    }

    fun clearIncomingTask(data: Bundle) {
        Log.e("TestReceiver", "onMethodCall: endAllCalls3", )
        context.sendBroadcast(Intent(ACTION_ENDED_CALL_INCOMING))
//        context.sendBroadcast(CallkitIncomingActivity.getIntentEnded(context))
        notificationId = data.getString(EXTRA_CALLKIT_ID, "callkit_incoming").hashCode()
//        getNotificationManager().cancel(notificationId)
    }

    fun clearMissCallNotification(data: Bundle) {
        notificationId = data.getString(EXTRA_CALLKIT_ID, "callkit_incoming").hashCode()
        getNotificationManager().cancel(notificationId)
        Handler(Looper.getMainLooper()).postDelayed({
            try {
                getNotificationManager().cancel(notificationId)
            } catch (error: Exception) {
            }
        }, 1000)
    }

    fun incomingChannelEnabled(): Boolean {
        val notificationManager = getNotificationManager()
        val channel = notificationManager.getNotificationChannel(NOTIFICATION_CHANNEL_ID_INCOMING)

        return notificationManager.areNotificationsEnabled() &&
                (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
                        channel != null &&
                        channel.importance > NotificationManagerCompat.IMPORTANCE_NONE) ||
                Build.VERSION.SDK_INT < Build.VERSION_CODES.O
    }

    private fun createNotificationChanel(
        incomingCallChannelName: String,
        missedCallChannelName: String,
    ) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            var channelCall = getNotificationManager().getNotificationChannel(NOTIFICATION_CHANNEL_ID_INCOMING)
            if (channelCall != null) {
                channelCall.setSound(null, null)
            } else {
                channelCall = NotificationChannel(
                        NOTIFICATION_CHANNEL_ID_INCOMING,
                        incomingCallChannelName,
                        NotificationManager.IMPORTANCE_HIGH
                ).apply {
                    description = ""
                    vibrationPattern =
                            longArrayOf(0, 1000, 500, 1000, 500)
                    lightColor = Color.RED
                    enableLights(true)
                    enableVibration(true)
                    setSound(null, null)
                }
            }
            channelCall.lockscreenVisibility = Notification.VISIBILITY_PUBLIC

            channelCall.importance = NotificationManager.IMPORTANCE_HIGH

            getNotificationManager().createNotificationChannel(channelCall)

            val channelMissedCall = NotificationChannel(
                    NOTIFICATION_CHANNEL_ID_MISSED,
                    missedCallChannelName,
                    NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = ""
                vibrationPattern = longArrayOf(0, 1000)
                lightColor = Color.RED
                enableLights(true)
                enableVibration(true)
            }
            channelMissedCall.importance = NotificationManager.IMPORTANCE_DEFAULT
            getNotificationManager().createNotificationChannel(channelMissedCall)
        }
    }

    private fun getAcceptPendingIntent(id: Int, data: Bundle): PendingIntent {
        val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)?.cloneFilter()
        intent?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        if (intent != null) {
            val intentTransparent = TransparentActivity.getIntentAccept(context, data)
            return PendingIntent.getActivities(
                    context,
                    id,
                    arrayOf(intent, intentTransparent),
                    getFlagPendingIntent()
            )
        } else {
            val acceptIntent = CallkitIncomingBroadcastReceiver.getIntentAccept(context, data)
            return PendingIntent.getBroadcast(
                    context,
                    id,
                    acceptIntent,
                    getFlagPendingIntent()
            )
        }
    }

    private fun getDeclinePendingIntent(id: Int, data: Bundle): PendingIntent {
        val declineIntent = CallkitIncomingBroadcastReceiver.getIntentDecline(context, data)
        return PendingIntent.getBroadcast(
                context,
                id,
                declineIntent,
                getFlagPendingIntent()
        )
    }

    private fun getTimeOutPendingIntent(id: Int, data: Bundle): PendingIntent {
        val timeOutIntent = CallkitIncomingBroadcastReceiver.getIntentTimeout(context, data)
        return PendingIntent.getBroadcast(
                context,
                id,
                timeOutIntent,
                getFlagPendingIntent()
        )
    }

    private fun getCallbackPendingIntent(id: Int, data: Bundle): PendingIntent {
        val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)?.cloneFilter()
        intent?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        if (intent != null) {
            val intentTransparent = TransparentActivity.getIntentCallback(context, data)
            return PendingIntent.getActivities(
                    context,
                    id,
                    arrayOf(intent, intentTransparent),
                    getFlagPendingIntent()
            )
        } else {
            val acceptIntent = CallkitIncomingBroadcastReceiver.getIntentCallback(context, data)
            return PendingIntent.getBroadcast(
                    context,
                    id,
                    acceptIntent,
                    getFlagPendingIntent()
            )
        }
    }

    private fun getActivityPendingIntent(id: Int, data: Bundle): PendingIntent {
        val intent = CallkitIncomingActivity.getIntent(context, data)
        return PendingIntent.getActivity(context, id, intent, getFlagPendingIntent())
    }

    private fun getAppPendingIntent(id: Int, data: Bundle): PendingIntent {
        val intent: Intent? = context.packageManager.getLaunchIntentForPackage(context.packageName)
        intent?.putExtra(CallkitIncomingBroadcastReceiver.EXTRA_CALLKIT_INCOMING_DATA, data)
        return PendingIntent.getActivity(context, id, intent, getFlagPendingIntent())
    }

    private fun getFlagPendingIntent(): Int {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
    }

    private fun getNotificationManager(): NotificationManagerCompat {
        return NotificationManagerCompat.from(context)
    }


    private fun getPicassoInstance(context: Context, headers: HashMap<String, Any?>): Picasso {
        val client = OkHttpClient.Builder()
                .addNetworkInterceptor { chain ->
                    val newRequestBuilder: okhttp3.Request.Builder = chain.request().newBuilder()
                    for ((key, value) in headers) {
                        newRequestBuilder.addHeader(key, value.toString())
                    }
                    chain.proceed(newRequestBuilder.build())
                }
                .build()
        return Picasso.Builder(context)
                .downloader(OkHttp3Downloader(client))
                .build()
    }


}
