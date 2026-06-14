package com.meta.wearable.dat.externalsampleapps.cameraaccess.gemini

import com.meta.wearable.dat.externalsampleapps.cameraaccess.settings.SettingsManager

object GeminiConfig {
    private const val GEMINI_API_KEY_PLACEHOLDER = "YOUR_GEMINI_API_KEY"

    const val WEBSOCKET_BASE_URL =
        "wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1beta.GenerativeService.BidiGenerateContent"
    const val MODEL = "models/gemini-3.1-flash-live-preview"

    const val INPUT_AUDIO_SAMPLE_RATE = 16000
    const val OUTPUT_AUDIO_SAMPLE_RATE = 24000
    const val AUDIO_CHANNELS = 1
    const val AUDIO_BITS_PER_SAMPLE = 16

    const val VIDEO_FRAME_INTERVAL_MS = 1000L
    const val VIDEO_JPEG_QUALITY = 50

    val systemInstruction: String
        get() = SettingsManager.geminiSystemPrompt

    val apiKey: String
        get() = SettingsManager.geminiAPIKey

    val openClawHost: String
        get() = SettingsManager.openClawHost

    val openClawPort: Int
        get() = SettingsManager.openClawPort

    val openClawHookToken: String
        get() = SettingsManager.openClawHookToken

    val openClawGatewayToken: String
        get() = SettingsManager.openClawGatewayToken

    fun websocketURL(): String? {
        if (!isConfigured) return null
        return "$WEBSOCKET_BASE_URL?key=$apiKey"
    }

    val isConfigured: Boolean
        get() = apiKeyConfigurationError() == null

    fun apiKeyConfigurationError(): String? {
        val trimmed = apiKey.trim()
        if (trimmed.isEmpty() || trimmed == GEMINI_API_KEY_PLACEHOLDER) {
            return "Gemini API key not configured. Open Settings and add your key from https://aistudio.google.com/apikey"
        }
        if (!(trimmed.startsWith("AIza") || trimmed.startsWith("AQ."))) {
            return "Gemini API key format looks invalid. Check the value copied from Google AI Studio."
        }
        if (trimmed.length < 35) {
            return "Gemini API key looks too short. Check the value copied from Google AI Studio."
        }
        return null
    }

    val isOpenClawConfigured: Boolean
        get() = openClawGatewayToken != "YOUR_OPENCLAW_GATEWAY_TOKEN"
                && openClawGatewayToken.isNotEmpty()
                && openClawHost != "http://YOUR_MAC_HOSTNAME.local"
}
