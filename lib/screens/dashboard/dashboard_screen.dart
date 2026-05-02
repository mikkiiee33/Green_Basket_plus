// lib/screens/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return '☀️ Good Morning';
    if (h < 17) return '🌤️ Good Afternoon';
    return '🌙 Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final profile  = context.watch<UserProfileProvider>().profile;
    final habits   = context.watch<HabitsProvider>();
    final meds     = context.watch<MedicationsProvider>();
    final checkups = context.watch<CheckupsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true, snap: true,
            backgroundColor: AppColors.background, elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_greeting(), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                Text(profile?.name ?? 'Welcome!', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              ],
            ),
            actions: [
              IconButton(
                icon: Stack(clipBehavior: Clip.none, children: [
                  const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
                  Positioned(right: -1, top: -1,
                    child: Container(width: 8, height: 8,
                      decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle))),
                ]),
                onPressed: () {},
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            sliver: SliverList(delegate: SliverChildListDelegate([

              // ── Health Score Row ────────────────────────────────
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(flex: 5, child: GBCard(
                  color: AppColors.primary,
                  child: Row(children: [
                    HealthScoreRing(score: habits.healthScore, size: 88),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Daily Health\nScore', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                      const SizedBox(height: 6),
                      Text('${habits.completedCount}/${habits.habits.length} habits', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.8))),
                      const SizedBox(height: 8),
                      ClipRRect(borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: habits.completionPercentage.clamp(0.0, 1.0),
                          backgroundColor: Colors.white.withOpacity(0.25),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          minHeight: 5)),
                    ])),
                  ]),
                )),
                const SizedBox(width: 10),
                Expanded(flex: 4, child: GBCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('💊', style: TextStyle(fontSize: 24)),
                  const SizedBox(height: 6),
                  Text('Adherence', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                  Text('${meds.adherencePercentage.toStringAsFixed(0)}%',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900,
                      color: meds.adherencePercentage >= 80 ? AppColors.success : AppColors.warning)),
                  const SizedBox(height: 6),
                  GBProgressBar(value: meds.adherencePercentage / 100,
                    color: meds.adherencePercentage >= 80 ? AppColors.success : AppColors.warning, height: 6),
                ]))),
              ]),

              const SizedBox(height: 16),

              // ── Today's Advice ──────────────────────────────────
              SectionTitle(title: "Today's Advice"),
              const SizedBox(height: 8),
              _AdviceCard(profile: profile),

              const SizedBox(height: 16),

              // ── Checkup Reminders ───────────────────────────────
              SectionTitle(title: 'Checkup Reminders', actionLabel: 'View All',
                onAction: () => Navigator.of(context).pushNamed('/checkups')),
              const SizedBox(height: 8),
              if (checkups.dueCheckups.isNotEmpty)
                _CheckupPreviewCard(checkup: checkups.dueCheckups.first, isDue: true),
              if (checkups.upcomingCheckups.isNotEmpty)
                Padding(padding: const EdgeInsets.only(top: 8),
                  child: _CheckupPreviewCard(checkup: checkups.upcomingCheckups.first, isDue: false)),
              if (checkups.dueCheckups.isEmpty && checkups.upcomingCheckups.isEmpty)
                GBCard(child: const Row(children: [
                  Text('✅', style: TextStyle(fontSize: 28)), SizedBox(width: 12),
                  Text('All checkups up to date!', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.success)),
                ])),

              const SizedBox(height: 16),

              // ── Activity ────────────────────────────────────────
              SectionTitle(title: "Today's Activity"),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: GBCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('🚶', style: TextStyle(fontSize: 26)),
                  const SizedBox(height: 6),
                  Text('Walking', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                  Text('20 min goal', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  const GBProgressBar(value: 0.65, color: AppColors.accent, height: 6),
                  const SizedBox(height: 4),
                  Text('13 min done', style: Theme.of(context).textTheme.bodySmall),
                ]))),
                const SizedBox(width: 10),
                Expanded(child: GBCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('💧', style: TextStyle(fontSize: 26)),
                  const SizedBox(height: 6),
                  Text('Hydration', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                  Text('2.5 L goal', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  const GBProgressBar(value: 0.44, color: AppColors.info, height: 6),
                  const SizedBox(height: 4),
                  Text('1.1 L done', style: Theme.of(context).textTheme.bodySmall),
                ]))),
              ]),

              const SizedBox(height: 16),

              // ── Quick Actions ────────────────────────────────────
              SectionTitle(title: 'Quick Actions'),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                QuickActionButton(emoji: '🤖', label: 'Ask\nGreenBot', color: AppColors.accent, onTap: () {}),
                QuickActionButton(emoji: '💊', label: 'Add\nMedicine', color: AppColors.primary, onTap: () {}),
                QuickActionButton(emoji: '🏃', label: 'Lifestyle', color: AppColors.info,
                  onTap: () => Navigator.of(context).pushNamed('/lifestyle')),
                QuickActionButton(emoji: '📊', label: 'Risk\nCheck', color: AppColors.warning,
                  onTap: () => Navigator.of(context).pushNamed('/risk-insights')),
              ]),

              const SizedBox(height: 24),
            ])),
          ),
        ],
      ),
    );
  }
}

class _AdviceCard extends StatelessWidget {
  final UserProfile? profile;
  const _AdviceCard({required this.profile});

  static const List<Map<String, String>> _advice = [
    {'e': '🌿', 't': 'Stay Hydrated',     'b': 'Drink at least 8 glasses of water today to support kidney health and energy.'},
    {'e': '🌞', 't': 'Morning Sunlight',  'b': 'Spend 15–20 minutes in morning sunlight for a natural Vitamin D boost.'},
    {'e': '🥗', 't': 'Eat More Greens',   'b': 'Include leafy vegetables like spinach or methi in at least one meal today.'},
    {'e': '🧘', 't': 'Breathe Deeply',    'b': 'Five deep breaths every hour lowers cortisol and blood pressure naturally.'},
    {'e': '😴', 't': 'Rest Well Tonight', 'b': 'Aim for 7–8 hrs quality sleep. Poor sleep raises risk of diabetes and heart disease.'},
    {'e': '🍎', 't': 'Eat a Fruit',       'b': 'Have one fresh seasonal fruit today — packed with vitamins, fibre, and antioxidants.'},
    {'e': '🚶', 't': 'Take a Walk',       'b': 'Even a 10-minute brisk walk improves insulin sensitivity and boosts mood.'},
  ];

  @override
  Widget build(BuildContext context) {
    final a = _advice[DateTime.now().weekday % _advice.length];
    return GBCard(
      color: AppColors.primarySurface,
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
          child: Text(a['e']!, style: const TextStyle(fontSize: 28))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(a['t']!, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.primary)),
          const SizedBox(height: 4),
          Text(a['b']!, style: Theme.of(context).textTheme.bodyMedium),
          if (profile?.hasDiabetes == true) ...[
            const SizedBox(height: 8),
            const StatusChip(label: '🩸 Diabetes Tip', color: AppColors.warning),
            const SizedBox(height: 4),
            Text('Monitor blood sugar before and 2 hrs after meals.', style: Theme.of(context).textTheme.bodySmall),
          ],
          if (profile?.hasBP == true) ...[
            const SizedBox(height: 8),
            const StatusChip(label: '💓 BP Tip', color: AppColors.info),
            const SizedBox(height: 4),
            Text('Avoid high-sodium snacks and practise deep breathing.', style: Theme.of(context).textTheme.bodySmall),
          ],
        ])),
      ]),
    );
  }
}

class _CheckupPreviewCard extends StatelessWidget {
  final Checkup checkup;
  final bool isDue;
  const _CheckupPreviewCard({required this.checkup, required this.isDue});

  @override
  Widget build(BuildContext context) {
    final color = isDue ? AppColors.error : AppColors.warning;
    return GBCard(child: Row(children: [
      Container(padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Text(checkup.icon, style: const TextStyle(fontSize: 24))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(checkup.name, style: Theme.of(context).textTheme.titleSmall),
        Text(checkup.description, style: Theme.of(context).textTheme.bodySmall),
      ])),
      StatusChip(label: isDue ? 'Due Now' : 'In ${checkup.daysUntilDue}d', color: color),
    ]));
  }
}

















// import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:greenbasket_plus/core/theme/app_theme.dart';
// import 'package:greenbasket_plus/main.dart';
// // import 'risk_predictor_screen.dart';

// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});
//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   int _waterCups = 3;
//   int _adviceIdx = 0;
//   final List<Map<String, dynamic>> _habits = [
//     {'icon':'🍎','name':'Eat 1 fruit','sub':'Apple, guava, or pear','pts':10,'done':true},
//     {'icon':'🥦','name':'1 vegetable serving','sub':'Sabzi or salad','pts':10,'done':true},
//     {'icon':'💧','name':'Drink 2.5L water','sub':'8+ cups throughout day','pts':15,'done':false},
//     {'icon':'🚶','name':'20 min walk','sub':'Morning or evening','pts':20,'done':true},
//     {'icon':'🥚','name':'Include protein','sub':'Dal, channa, or egg','pts':10,'done':true},
//     {'icon':'😴','name':'Sleep by 10:30 PM','sub':'7–8 hours of rest','pts':15,'done':false},
//     {'icon':'🚫','name':'Avoid processed food','sub':'No chips, packaged snacks','pts':10,'done':false},
//   ];

//   final List<String> _advices = [
//     'Your BP is controlled — great! Try adding a banana today for potassium 🍌',
//     'Diabetes tip: Replace white rice with small portions of red rice today 🍚',
//     'Stay hydrated! Drink a glass of water right now — dehydration spikes sugar 💧',
//   ];

//   int get _score {
//     final done = _habits.where((h) => h['done'] == true).length;
//     final habitsScore = (done / _habits.length * 40).round();
//     final medScore = 34; // 85% adherence
//     final waterScore = (_waterCups / 8 * 26).round();
//     return (habitsScore + medScore + waterScore).clamp(0, 100);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.background,
//       body: CustomScrollView(
//         slivers: [
//           SliverAppBar(
//             expandedHeight: 0,
//             floating: true,
//             backgroundColor: AppTheme.surface,
//             title: Row(children: [
//               Container(width:32,height:32,decoration:BoxDecoration(color:AppTheme.primary,borderRadius:BorderRadius.circular(10)),
//                 child:const Center(child:Text('🌿',style:TextStyle(fontSize:17)))),
//               const SizedBox(width:8),
//               RichText(text:TextSpan(children:[
//                 TextSpan(text:'GreenBasket',style:TextStyle(fontFamily: 'Sora',fontSize:17,fontWeight:FontWeight.w700,color:AppTheme.primary)),
//                 TextSpan(text:'+',style:TextStyle(fontFamily: 'Sora',fontSize:17,fontWeight:FontWeight.w700,color:AppTheme.amber)),
//               ])),
//             ]),
//             actions: [
//               IconButton(icon:Icon(Icons.notifications_outlined,color:AppTheme.amber),onPressed:(){}),
//               Padding(padding:const EdgeInsets.only(right:12),child:
//                 CircleAvatar(backgroundColor:AppTheme.primaryLight,radius:17,
//                   child:Text('R',style:TextStyle(color:AppTheme.primary,fontWeight:FontWeight.w700,fontSize:14)))),
//             ],
//           ),
//           SliverToBoxAdapter(child: Column(children: [
//             _buildScoreHero(),
//             _buildAdviceBanner(),
//             _buildWaterTracker(),
//             _buildSectionLabel('Today\'s Habit Checklist'),
//             _buildHabits(),
//             _buildSectionLabel('Upcoming Reminders'),
//             _buildUpcoming(),
//             _buildSectionLabel('Health Risk Assessment'),
//             _buildRiskBanner(),
//             _buildSectionLabel('This Week\'s Streak'),
//             _buildStreak(),
//             const SizedBox(height:24),
//           ])),
//         ],
//       ),
//     );
//   }

//   Widget _buildScoreHero() {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
//           colors: [const Color(0xFF1B5E34), AppTheme.primary, AppTheme.teal]),
//         borderRadius: const BorderRadius.only(bottomLeft:Radius.circular(28),bottomRight:Radius.circular(28)),
//       ),
//       padding: const EdgeInsets.fromLTRB(24,20,24,28),
//       child: Column(children: [
//         Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//           Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Text('Good morning,', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
//             Text('Rajesh 👋', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700, fontFamily: 'Sora')),
//           ]),
//           Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
//             Text('Today', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11)),
//             Text('Sat, Mar 14', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
//           ]),
//         ]),
//         const SizedBox(height: 20),
//         Row(children: [
//           SizedBox(width:80,height:80,child:Stack(alignment:Alignment.center,children:[
//             CircularProgressIndicator(value:_score/100,strokeWidth:7,backgroundColor:Colors.white.withValues(alpha: 0.2),valueColor:const AlwaysStoppedAnimation(Colors.white)),
//             Text('$_score',style:const TextStyle(color:Colors.white,fontSize:22,fontWeight:FontWeight.w700,fontFamily: 'Sora')),
//           ])),
//           const SizedBox(width:20),
//           Expanded(child:Column(children:[
//             _scoreRow('💊 Medication','85%'),
//             _scoreRow('🚶 Walking','70%'),
//             _scoreRow('💧 Hydration','${_waterCups}/8 cups'),
//             _scoreRow('🍎 Habits','${_habits.where((h)=>h['done']==true).length}/${_habits.length} done'),
//           ])),
//         ]),
//       ]),
//     );
//   }

//   Widget _scoreRow(String label, String val) => Padding(
//     padding: const EdgeInsets.symmetric(vertical: 4),
//     child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//       Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12)),
//       Text(val, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
//     ]),
//   );

//   Widget _buildAdviceBanner() {
//     return GestureDetector(
//       onHorizontalDragEnd: (d) {
//         setState(() => _adviceIdx = (_adviceIdx + (d.velocity.pixelsPerSecond.dx < 0 ? 1 : -1)) % _advices.length);
//       },
//       child: Container(
//         margin: const EdgeInsets.fromLTRB(16,14,16,0),
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(16)),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Text('TODAY\'S HEALTH TIP', style: TextStyle(fontSize:11,fontWeight:FontWeight.w700,color:Colors.white.withValues(alpha: 0.7),letterSpacing:0.06)),
//           const SizedBox(height:6),
//           Text(_advices[_adviceIdx], style: const TextStyle(color:Colors.white,fontSize:15,fontWeight:FontWeight.w600,height:1.4)),
//           const SizedBox(height:10),
//           Row(children: List.generate(_advices.length,(i)=>AnimatedContainer(
//             duration:const Duration(milliseconds:250),
//             margin:const EdgeInsets.only(right:5),
//             width:i==_adviceIdx?18:6,height:6,
//             decoration:BoxDecoration(color:i==_adviceIdx?Colors.white:Colors.white.withValues(alpha: 0.4),borderRadius:BorderRadius.circular(3)),
//           ))),
//         ]),
//       ),
//     );
//   }

//   Widget _buildWaterTracker() {
//     return Card(
//       margin: const EdgeInsets.fromLTRB(16,12,16,0),
//       child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
//         Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//           const Text('💧 Water Today', style: TextStyle(fontSize:14, fontWeight:FontWeight.w600)),
//           Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:3),
//             decoration:BoxDecoration(color:AppTheme.blueLight,borderRadius:BorderRadius.circular(20)),
//             child:Text('$_waterCups / 8 cups',style:TextStyle(fontSize:11,fontWeight:FontWeight.w600,color:AppTheme.blue))),
//         ]),
//         const SizedBox(height:12),
//         Wrap(spacing:8,runSpacing:8,children:List.generate(8,(i)=>GestureDetector(
//           onTap:()=>setState(()=>_waterCups=i<_waterCups?i:(i+1)),
//           child:Container(width:36,height:36,decoration:BoxDecoration(
//             color:i<_waterCups?AppTheme.tealLight:AppTheme.background,
//             borderRadius:BorderRadius.circular(10),
//             border:Border.all(color:i<_waterCups?AppTheme.teal:AppTheme.border,width:i<_waterCups?1.5:0.5)),
//             child:const Center(child:Text('💧',style:TextStyle(fontSize:18)))),
//         ))),
//       ])),
//     );
//   }

//   Widget _buildSectionLabel(String label) => Padding(
//     padding: const EdgeInsets.fromLTRB(20,16,20,8),
//     child: Text(label.toUpperCase(), style: const TextStyle(fontSize:11,fontWeight:FontWeight.w700,color:AppTheme.textMuted,letterSpacing:0.06)),
//   );

//   Widget _buildHabits() {
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal:16),
//       child: Padding(padding: const EdgeInsets.symmetric(horizontal:16,vertical:8), child:
//         Column(children: List.generate(_habits.length,(i){
//           final h = _habits[i];
//           return InkWell(
//             onTap:()=>setState((){_habits[i]['done']=!_habits[i]['done'];}),
//             child:Padding(padding:const EdgeInsets.symmetric(vertical:9),child:Row(children:[
//               AnimatedContainer(duration:const Duration(milliseconds:200),
//                 width:24,height:24,decoration:BoxDecoration(
//                   color:h['done']==true?AppTheme.primary:Colors.transparent,
//                   borderRadius:BorderRadius.circular(7),
//                   border:Border.all(color:h['done']==true?AppTheme.primary:AppTheme.border,width:1.5)),
//                 child:h['done']==true?const Icon(Icons.check,size:14,color:Colors.white):null),
//               const SizedBox(width:10),
//               Text(h['icon'],style:const TextStyle(fontSize:20)),
//               const SizedBox(width:10),
//               Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
//                 Text(h['name'],style:TextStyle(fontSize:14,fontWeight:FontWeight.w500,
//                   decoration:h['done']==true?TextDecoration.lineThrough:null,
//                   color:h['done']==true?AppTheme.textMuted:AppTheme.textPrimary)),
//                 Text(h['sub'],style:const TextStyle(fontSize:12,color:AppTheme.textMuted)),
//               ])),
//               Container(padding:const EdgeInsets.symmetric(horizontal:7,vertical:2),
//                 decoration:BoxDecoration(color:AppTheme.amberLight,borderRadius:BorderRadius.circular(10)),
//                 child:Text('+${h['pts']}',style:TextStyle(fontSize:11,fontWeight:FontWeight.w700,color:AppTheme.amber))),
//             ]),
//           ),
//           );
//         })),
//       ),
//     );
//   }

//   Widget _buildUpcoming() {
//     final items = [
//       {'icon':'💊','bg':AppTheme.amberLight,'name':'Metformin 500mg','sub':'Next dose in 2 hours','due':'2:00 PM','urgent':true},
//       {'icon':'🩺','bg':AppTheme.blueLight,'name':'Doctor Visit','sub':'Last: Jan 14, 2026','due':'Due soon','urgent':true},
//       {'icon':'🩸','bg':AppTheme.tealLight,'name':'Sugar Test','sub':'Last: Feb 28, 2026','due':'On track','urgent':false},
//     ];
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal:16),
//       child: Padding(padding:const EdgeInsets.all(4),child:Column(children:items.map((item)=>ListTile(
//         leading:Container(width:42,height:42,decoration:BoxDecoration(color:item['bg'] as Color,borderRadius:BorderRadius.circular(12)),
//           child:Center(child:Text(item['icon'] as String,style:const TextStyle(fontSize:20)))),
//         title:Text(item['name'] as String,style:const TextStyle(fontSize:14,fontWeight:FontWeight.w600)),
//         subtitle:Text(item['sub'] as String,style:const TextStyle(fontSize:12,color:AppTheme.textMuted)),
//         trailing:Text(item['due'] as String,style:TextStyle(fontSize:13,fontWeight:FontWeight.w600,
//           color:(item['urgent'] as bool)?AppTheme.coral:AppTheme.primary)),
//       )).toList())),
//     );
//   }

//   Widget _buildRiskBanner() {
//     return GestureDetector(
//       onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const RiskPredictorScreen())),
//       child:Container(
//         margin:const EdgeInsets.symmetric(horizontal:16),
//         padding:const EdgeInsets.all(16),
//         decoration:BoxDecoration(
//           color:AppTheme.purpleLight,
//           borderRadius:BorderRadius.circular(16),
//           border:Border.all(color:AppTheme.purple.withValues(alpha: 0.3))),
//         child:Row(children:[
//           const Text('🧠',style:TextStyle(fontSize:32)),
//           const SizedBox(width:14),
//           Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
//             Text('Check Your Health Risk',style:TextStyle(fontSize:15,fontWeight:FontWeight.w700,color:AppTheme.purple)),
//             Text('AI predicts Diabetes, Heart Disease & Obesity risk based on your lifestyle.',style:TextStyle(fontSize:12,color:AppTheme.purple.withValues(alpha: 0.8))),
//           ])),
//           Icon(Icons.arrow_forward_ios_rounded,size:16,color:AppTheme.purple),
//         ]),
//       ),
//     );
//   }

//   Widget _buildStreak() {
//     final days = ['M','T','W','T','F','S','S'];
//     final scores = [true,true,false,true,true,true,false];
//     return Card(
//       margin:const EdgeInsets.symmetric(horizontal:16),
//       child:Padding(padding:const EdgeInsets.all(16),child:Column(children:[
//         Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
//           const Text('Overall Consistency',style:TextStyle(fontSize:14,fontWeight:FontWeight.w600)),
//           const Text('71%',style:TextStyle(fontSize:16,fontWeight:FontWeight.w700,color:AppTheme.primary)),
//         ]),
//         const SizedBox(height:8),
//         ClipRRect(borderRadius:BorderRadius.circular(4),child:
//           LinearProgressIndicator(value:0.71,minHeight:8,backgroundColor:AppTheme.primaryLight,
//             valueColor:const AlwaysStoppedAnimation(AppTheme.primary))),
//         const SizedBox(height:14),
//         Row(mainAxisAlignment:MainAxisAlignment.spaceAround,children:List.generate(7,(i)=>Column(children:[
//           Container(width:10,height:10,decoration:BoxDecoration(
//             shape:BoxShape.circle,
//             color:scores[i]?AppTheme.primary:AppTheme.coralLight)),
//           const SizedBox(height:4),
//           Text(days[i],style:const TextStyle(fontSize:10,color:AppTheme.textMuted)),
//         ]))),
//       ])),
//     );
//   }
// }