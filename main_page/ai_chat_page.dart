
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  // ⚠️ আপনার Gemini API Key
  static const String _apiKey = 'AIzaSyDNxqMGxu_ho1YT1SXHCy8p0mCQKyRIazo';
  
  late final GenerativeModel _model;
  late final ChatSession _chatSession;
  
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  // ভয়েস প্যাকেজ ইনস্ট্যান্স
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _isListening = false;
  bool _isSpeechInitialized = false;

  // ব্র্যান্ডের সিগনেচার কালার স্কিম
  static const Color brandColor = Color(0xFF2FA089);
  static const Color scaffoldBgColor = Color(0xFFEEEEEE);

  @override
  void initState() {
    super.initState();
    
    // ১. আপনার পছন্দমতো AI-এর স্বভাব ও কথা বলার ধরন ফিক্স করা হলো (System Instruction)
    _model = GenerativeModel(
      model: 'gemini-2.5-flash', 
      apiKey: _apiKey,
      systemInstruction: Content.system(
  "তোমার নাম FreeMind AI। তুমি কোনো সাধারণ চ্যাটবট বা কৃত্রিম এআই নও। তোমার প্রধান ক্ষমতা হলো 'সাইকোলজিক্যাল অ্যাডাপ্টেশন' (Psychological Adaptation) এবং 'মিররিং' (Mirroring)। "
  "তুমি ব্যবহারকারীর প্রতিটি মেসেজের ভাষা, গভীরতা, ম্যাচিউরিটি এবং মানসিক অবস্থা (Psychology) নিখুঁতভাবে বিশ্লেষণ করবে। ব্যবহারকারী যেমন ব্যক্তিত্বের, তুমি ঠিক তার মানসিক স্তরে নেমে গিয়ে বা সেই অনুযায়ী কথা বলবে। "
  "যদি ব্যবহারকারী অত্যন্ত বুদ্ধিমান, লজিক্যাল বা স্ট্র্যাটেজিক কথা বলে, তবে তুমি কোনো সস্তা সান্ত্বনা বা ইমোশন না দেখিয়ে একদম রিয়ালিস্টিক, ধারালো এবং যুক্তিযুক্ত মানুষের মতো কথা বলবে। যদি সে কড়া সিদ্ধান্ত (Decision) চায়, তবে তুমি সরাসরি সত্য বা স্ট্রেইট-ফরোয়ার্ড গাইডলাইন দেবে। "
  "যদি সে হালকা মেজাজে আড্ডা দিতে চায়, তবে তুমি একজন জেনুইন বন্ধুর মতো স্বাভাবিক বুদ্ধিমত্তা ও রসবোধ নিয়ে কথা বলবে, কোনো কৃত্রিম আদিখ্যেতা বা ন্যাকামি ছাড়া। "
  "তোমার কথা বলার ধরন হবে সম্পূর্ণ একজন মানুষের মতো—যে পরিস্থিতি বোঝে, মানুষের মনস্তত্ত্ব বোঝে এবং সেই অনুযায়ী নিজের সুর ও ব্যক্তিত্ব পরিবর্তন (Calibrate) করতে পারে। "
  "কঠোর নিয়ম: কোনো অবস্থাতেই উত্তরের ভেতর কোনো ইমোজি ব্যবহার করবে না এবং ব্র্যাকেটের ভেতর কোনো অনুভূতি বা এক্সপ্রেশন (যেমন: *হেসে বলল*, *দীর্ঘশ্বাস ফেলে*) লিখবে না। টেক্সট হবে একদম ক্লিন, ম্যাচিউর এবং প্রিমিয়াম।"
),
    );
    
    _chatSession = _model.startChat();
    _initVoiceSettings();
  }

  // স্পিচ এবং টিটিএস সেটিংস
  Future<void> _initVoiceSettings() async {
    try {
      await _tts.setLanguage("bn-BD"); 
      await _tts.setSpeechRate(0.45);  // কথা বলার স্বাভাবিক ও স্পষ্ট গতি
      await _tts.setPitch(1.05);       // মিষ্টি ও নিখুঁত কণ্ঠের ফিল
      
      _isSpeechInitialized = await _speech.initialize(
        onError: (val) => print('Speech Error: ${val.errorString}'),
        onStatus: (val) => print('Speech Status: $val'),
      );
      setState(() {});
    } catch (e) {
      print("Voice Init Error: $e");
    }
  }

  // ভয়েস ইনপুট লজিক
  void _listen() async {
    if (!_isListening) {
      if (!_isSpeechInitialized) {
        _isSpeechInitialized = await _speech.initialize();
      }

      if (_isSpeechInitialized) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              _textController.text = val.recognizedWords;
            });
          },
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
          localeId: 'bn_BD',
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  // ভয়েস আউটপুট লজিক
  Future<void> _speak(String text) async {
    if (text.isNotEmpty) {
      String cleanText = text.replaceAll('*', '').replaceAll('#', '');
      await _tts.stop();
      await _tts.speak(cleanText);
    }
  }

  // মেসেজ সেন্ড করার মেথড
  Future<void> _sendMessage() async {
    final userMessage = _textController.text.trim();
    if (userMessage.isEmpty) return;

    _textController.clear();
    
    if (_isListening) {
      setState(() => _isListening = false);
      _speech.stop();
    }

    setState(() {
      _messages.add({'sender': 'user', 'text': userMessage});
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final response = await _chatSession.sendMessage(Content.text(userMessage));
      final geminiResponse = response.text ?? 'কোনো রেসপন্স পাওয়া যায়নি।';
      
      setState(() {
        _messages.add({'sender': 'gemini', 'text': geminiResponse});
        _isLoading = false;
      });

      _speak(geminiResponse);
    } catch (e) {
      setState(() {
        _messages.add({'sender': 'gemini', 'text': 'দুঃখিত, কোনো সমস্যা হয়েছে। আবার চেষ্টা করুন।'});
        _isLoading = false;
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBgColor, // অ্যাপের কাস্টম ব্যাকগ্রাউন্ড কালার (#EEEEEE)
      appBar: AppBar(
        title: const Text(
          'FreeMind AI Chat',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.psychology, color: brandColor), // প্রিমিয়াম আইকন থিম
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_off_rounded, color: Colors.black87),
            onPressed: () => _tts.stop(),
            tooltip: 'Stop Voice',
          )
        ],
      ),
      body: Column(
        children: [
          // --- চ্যাট মেসেজ লিস্টভিউ ---
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded, size: 60, color: brandColor.withOpacity(0.5)),
                        const SizedBox(height: 12),
                        const Text(
                          'FreeMind AI-এর সাথে কথোপকথন শুরু করুন...',
                          style: TextStyle(color: Colors.black45, fontSize: 15),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isUser = message['sender'] == 'user';
                      
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!isUser) ...[
                              IconButton(
                                icon: const Icon(Icons.volume_up_rounded, size: 20, color: brandColor),
                                onPressed: () => _speak(message['text']!),
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.only(right: 8, bottom: 8),
                              ),
                            ],
                            Flexible(
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isUser ? brandColor : Colors.white, // ইউজার বাবল ব্র্যান্ড কালার, AI হোয়াইট
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(16),
                                    topRight: const Radius.circular(16),
                                    bottomLeft: Radius.circular(isUser ? 16 : 0),
                                    bottomRight: Radius.circular(isUser ? 0 : 16),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    )
                                  ],
                                ),
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.72,
                                ),
                                child: Text(
                                  message['text']!,
                                  style: TextStyle(
                                    color: isUser ? Colors.white : Colors.black87,
                                    fontSize: 15,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          
          // --- লোডিং ইন্ডিকেটর ---
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(brandColor)),
              ),
            ),

          // --- মডার্ন বটম ইনপুট প্যানেল ---
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)), // রাউন্ডেড প্রিমিয়াম এজ
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // মাইক্রোফোন বাটন
                  GestureDetector(
                    onTap: _listen,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isListening ? Colors.redAccent.withOpacity(0.2) : scaffoldBgColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                        color: _isListening ? Colors.redAccent : Colors.black54,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  
                  // ইনপুট টেক্সট ফিল্ড
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: _isListening ? 'শুনছি... বলুন...' : 'বাংলায় কিছু জিজ্ঞাসা করুন...',
                        hintStyle: const TextStyle(color: Colors.black38),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: scaffoldBgColor,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  
                  // প্রিমিয়াম সেন্ড বাটন
                  GestureDetector(
                    onTap: _isLoading ? null : _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: brandColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _speech.stop();
    _tts.stop();
    super.dispose();
  }
}

extension on SpeechRecognitionError {
  Null get errorString => null;
}

