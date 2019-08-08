import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:listview_flutter_app/question.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


import 'exam.dart';
import 'mydrawer.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Questions List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RandomWords(),
    );
  }
}

class RandomWords extends StatefulWidget {
  @override
  RandomWordsState createState() => RandomWordsState();
}

class RandomWordsState extends State<RandomWords> {
  final _suggestions = <Question>[];
  final _biggerFont = const TextStyle(fontSize: 17.0);
  String _barTitle = "等待开始";
  bool isStarted = false;
  DateTime _startTime;
  final Set<Exam> _submitedExams = Set<Exam>();

  init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var str = prefs.getString("examHistories");
    var barColor = prefs.getInt("bar_color");
    var cardColor = prefs.getInt("card_color");

    setState(() {
      if(str!=null) {
        print('get examHistory为:$str');
        _submitedExams.clear();
        List examsList = json.decode(str);
        var exams = examsList.map((x) => new Exam.fromJson(x));
        _submitedExams.addAll(exams);
      }
      if(barColor!=null){
        print('get current color:$barColor');
        currentColor=Color(barColor);
      }
      if(cardColor!=null){
        print('get current card color:$cardColor');
        currentBgColor=Color(cardColor);
      }

    });


  }
  @override
  void initState() {
    //页面初始化
    super.initState();
    init();
  }
  @override
  Widget build(BuildContext context) {
//_suggestions.add(generateWordPairs().take(10));
    return Scaffold(
      //backgroundColor: currentBgColor,
      appBar: AppBar(
        backgroundColor: currentColor,
        title: Text(_barTitle),
        actions: <Widget>[
          // Add 3 lines from here...
          _buildStartButton(),
          _buildSubmitButton(),
          //IconButton(icon: Icon(Icons.list), onPressed: _pushSaved),
          PopupMenuButton(
            itemBuilder: (BuildContext context) =>
            <PopupMenuItem<String>>[
              PopupMenuItem<String>(child:ListTile(leading: Icon(Icons.star),title:Text("积分历史")), value: "scores",),
              PopupMenuItem<String>(child: ListTile(leading: Icon(Icons.trending_up),title:Text("最新题目")), value: "new",),
              PopupMenuItem<String>(child: ListTile(leading: Icon(Icons.settings),title:Text("设置")), value: "setting",),
              PopupMenuItem<String>(child: ListTile(leading: Icon(Icons.info),title:Text("关于")), value: "about",),
              PopupMenuItem<String>(child: ListTile(leading: Icon(Icons.share),title:Text("分享")), value: "share",),
              PopupMenuItem<String>(child: ListTile(leading: Icon(Icons.color_lens),title:Text("主题颜色")), value: "color",),
              PopupMenuItem<String>(child: ListTile(leading: Icon(Icons.color_lens),title:Text("背景颜色")), value: "bgcolor",),
              PopupMenuItem<String>(child: ListTile(leading: Icon(Icons.color_lens),title:Text("重置颜色")), value: "resetcolor",),

            ],
            onSelected: (String action) {
              switch (action) {
                case "scores":
                  _pushSaved();
                  break;
                case "new":
                  _start(latest: true);
                  break;
                case "color":
                  _showColorSetting();
                  break;
                case "bgcolor":
                  _showColorSetting(isBgColor: true);
                  break;
                case "resetcolor":
                  setState(() {
                    currentColor = Colors.blue;
                    currentBgColor = Colors.white;
                  });
                  break;
              }
            },
            onCanceled: () {
              print("onCanceled");
            },
          )
        ],
      ),
      body: _buildSuggestions(),
      floatingActionButton: _buildFloatButton(),
      drawer:new MyDrawer(),
    );
  }
  Color currentBgColor = Colors.white;
  Color pickerColor = Color(0xff443a49);
  Color currentColor = Colors.blueAccent;
  ValueChanged<Color> onColorChanged;
  changeColor(Color color) {
    setState((){
      pickerColor = color;
    });
  }
  void _showColorSetting({isBgColor=false}){
    oriColor=currentColor;
    showDialog(
      context: context,
      child: AlertDialog(
        title: const Text('选择颜色'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: changeColor,
            enableLabel: true,
            pickerAreaHeightPercent: 0.8,
          ),
          // Use Material color picker
          // child: MaterialPicker(
          //   pickerColor: pickerColor,
          //   onColorChanged: changeColor,
          //   enableLabel: true, // only on portrait mode
          // ),
          //
          // Use Block color picker
          // child: BlockPicker(
          //   pickerColor: currentColor,
          //   onColorChanged: changeColor,
          // ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('保存'),
            onPressed: () {
              setState(() => !isBgColor? currentColor = pickerColor:currentBgColor=pickerColor);
              if(isBgColor)
                saveCardColorToSystem(currentBgColor.value);
              else
                saveBarColorToSystem(currentColor.value);
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text('取消'),
            onPressed: () {
              setState(() => !isBgColor? currentColor = oriColor:currentBgColor=oriColor);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
  void saveBarColorToSystem(color) async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setInt('bar_color', color);
  }
  void saveCardColorToSystem(color) async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setInt('card_color', color);
  }
  Color oriColor;
  Opacity _buildFloatButton(){
   return new Opacity(
      opacity: !isStarted ? 1.0 : 0.0,
      child: new FloatingActionButton(
          onPressed: _start,
          tooltip: '开始',
          child: new Icon(Icons.create),
          elevation: 3.0,
          highlightElevation: 2.0,
          backgroundColor: currentColor,
        ),
      );

  }
  void _collectExamSummary(int score, int duration, DateTime startDate) {
    Exam exam = new Exam(score, startDate, duration);
    _submitedExams.add(exam);
    _saveHistory();
  }
  void _saveHistory() async{
    String str= json.encode(_submitedExams.toList());
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('examHistories', str);
    print('存储examHistory为:$str');
  }
  void _submit() {
    setState(() {
      isSumited = true;
      isStarted = false;
      var duration = DateTime.now().difference(_startTime).inSeconds;
      var score = _suggestions
          .map((x) => x.userAnswer == x.correctedAnswer ? 10 : 0)
          .reduce((v, el) => (v + el));
      _barTitle = '成绩：' + score.toString();
      _barTitle += "  用时：" + duration.toString() + '秒';
      _collectExamSummary(score, duration, _startTime);
    });
  }

  void _start({bool latest=false}) {
    setState(() {
      _suggestions.clear();
      List<Question> s=generateWordPairs();
      print(latest);
      if(!latest)
        s.shuffle();
      else
      {
        s.sort((a,b)=>a.id.compareTo(b.id));

      }
      _suggestions.addAll(s.reversed.take(10)); /*4*/
      isSumited = false;
      isStarted = true;
      var format = new DateFormat('HH:mm a');
      _startTime = DateTime.now();
      var tt= format.format(_startTime);
      _barTitle = '$tt 考试中……';
      _suggestions.forEach((x) => x.userAnswer = "");
    });
  }

  Widget _buildStartButton() {
    if (isStarted) return Container();
    return IconButton(icon: Icon(Icons.create),tooltip: '开始', onPressed: _start);
  }

  Widget _buildSubmitButton() {
    if (isStarted)
      return IconButton(icon: Icon(Icons.done), onPressed: _submit);
    return Container();
  }

  void _pushSaved() {
    var format = new DateFormat('yyyy-MM-dd HH:mm:ss');
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        // Add 20 lines from here...
        builder: (BuildContext context) {
          final Iterable<Card> tiles = _submitedExams.toList().reversed.map(
            (Exam exam) {
              return Card(
                  margin: const EdgeInsets.all(4.0),
                  color: currentBgColor,
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0),
                        bottomLeft: Radius.circular(10.0),
                        bottomRight: Radius.circular(10.0)),
                    ),
                  child: ListTile(
                title: Text(
                  "积分：+${exam.score}  日期：${format.format(exam.date)} 用时：${exam.duration}秒",
                  style: _biggerFont,
                ),
              ));

            },
          );
          final List<Widget> divided = ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList();
          return Scaffold(

            appBar: AppBar(
              backgroundColor: currentColor,
              title: Text('总积分：'+((_submitedExams.length==0)?'0':_submitedExams.map((x)=>x.score).reduce((x,y)=>x+y).toString())),
            ),
            body: ListView(children: divided),
          );
        },
      ),
    );
  }

  Widget _buildSuggestions() {
    return ListView.builder(
        itemCount: 20,
        padding: const EdgeInsets.all(4.0),
        itemBuilder: /*1*/ (context, i) {
          if (i.isOdd) return Container();//Divider(); /*2*/

          final index = i ~/ 2; /*3*/

          if (index >= _suggestions.length) {
            var s=generateWordPairs();
            s.shuffle();
            _suggestions.addAll(s.take(10)); /*4*/
          }

          return _buildRow(_suggestions[index]);
        });
  }

  Widget _buildRow(Question pair) {
    //final bool alreadySaved = _saved.contains(pair);
    Color color = Theme.of(context).primaryColor;

    Widget titleSection = Container(
      //padding: const EdgeInsets.all(5),
      margin: const EdgeInsets.all(5),
      child: Row(
        children: [
          Image.asset(
            'images/bottle.png',
            width: 150,
            //height: 100,
            fit: BoxFit.fitHeight,
          ),
          Expanded(
            /*1*/
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /*2*/
                Container(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    (_suggestions.indexOf(pair)+1).toString()+'. '+pair.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 17,
                      wordSpacing: 3,
                      letterSpacing: 0.5,
                    ),

                  ),
                ),
                /*
                Text(
                  pair.title,
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
                */
              ],
            ),
          ),
          /*3*/
          /*
          Icon(
            //Icons.star,
            //color: Colors.red[500],
            alreadySaved ? Icons.favorite : Icons.favorite_border,
            color: alreadySaved ? Colors.red : null,
          ),
          Text('41'),
*/
        ],
      ),
    );
    Widget buttonSection = Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildButtonColumn(color, Icons.call, 'A', pair),
          _buildButtonColumn(color, Icons.near_me, 'B', pair),
          _buildButtonColumn(color, Icons.share, 'C', pair),
          _buildButtonColumn(color, Icons.share, 'D', pair),
          _buildCheckResultColumn(color, Icons.share, '评分:', pair),
        ],
      ),
    );
    Widget textSection = Container(
      padding: const EdgeInsets.all(24),
      child: Text(
        'Lake Oeschinen lies at the foot of the Blüemlisalp in the Bernese ',
        softWrap: true,
      ),
    );
    return Card(
        //semanticContainer: false,
        color: currentBgColor,
        //z轴的高度，设置card的阴影
        elevation: 10.0,
        //设置shape，这里设置成了R角
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
              bottomLeft: Radius.circular(20.0),
              bottomRight: Radius.circular(20.0)),
        ),
        //对Widget截取的行为，比如这里 Clip.antiAlias 指抗锯齿
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: <Widget>[
            titleSection,
            buttonSection,
            //textSection,
          ],

      /*
      title: Text(
        pair.title,
        style: _biggerFont,
      ),

      trailing: Icon(   // Add the lines from here...
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: () {      // Add 9 lines from here...
        setState(() {
          if (alreadySaved) {
            _saved.remove(pair);
          } else {
            _saved.add(pair);
          }
        });
      },*/
    ));
    return Column(
      children: <Widget>[
        titleSection,
        buttonSection,
        //textSection,
      ],

      /*
      title: Text(
        pair.title,
        style: _biggerFont,
      ),

      trailing: Icon(   // Add the lines from here...
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: () {      // Add 9 lines from here...
        setState(() {
          if (alreadySaved) {
            _saved.remove(pair);
          } else {
            _saved.add(pair);
          }
        });
      },*/
    );
  }

  //String groupValue = "A";
  void updateGroupValue(Question pair, String v) {
    setState(() {
      pair.userAnswer = v;
    });
  }

  bool isSumited = false;
  Row _buildCheckResultColumn(
      Color color, IconData icon, String label, Question pair) {
    if (!isSumited)
      return new Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: []);
    return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label),
          Text(pair.userAnswer == pair.correctedAnswer ? '正确' : ' X ',
              style: TextStyle(
                  color: pair.userAnswer == pair.correctedAnswer
                      ? Colors.green
                      : Colors.redAccent))
        ]);
  }

  Row _buildButtonColumn(
      Color color, IconData icon, String label, Question pair) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        new Radio(
            value: label,
            groupValue: pair.userAnswer,
            onChanged: (T) {
              updateGroupValue(pair, T);
            }),
        Text(label),
        /*
      Icon(icon, color: color),
      Container(
        margin: const EdgeInsets.only(top: 8),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: color,
          ),
        ),
      ),
      */
      ],
    );
  }

  List<Question> list = new List();
  generateWordPairs() {
    if (list.length > 0) return list;
    /*
    List a = ["A", "B", "C", "D"];

    for (int i = 1; i < 100; i++) {
      int r = Random().nextInt(4);
      list.add(new WordPair(i, "Question " + i.toString(), a[r]));
    }*/
    QuestionManager.generate(list);
    return list;
  }
}





class QuestionManager{
  static void generate(List<Question> questionEngList){
    questionEngList.add(new Question(1,"捡起这个苹果。\r\n(     ) up the apple.\r\nA) pick\r\nB) raise\r\nC) Pick \r\nD) Raise","C"));
    questionEngList.add(new Question(2,"指向秋千。\r\n （    ）to the swing.\n"  +
        "A) go\n"  +
        "B) point\n"  +
        "C) Go\n"  +
        "D) Point","D"));
    questionEngList.add(new Question(3,"尝尝这个橘子。\r\n(   ) the orange.\n"  +
        "A) Eat\n"  +
        "B) Taste\n"  +
        "C) eat \n"  +
        "D) Feel","B"));
    questionEngList.add(new Question(4,"摸摸我的手。\r\n(   ) my hand.\n"  +
        "A) Raise\n"  +
        "B) raise\n"  +
        "C) touch \n"  +
        "D) Touch","D"));
    questionEngList.add(new Question(5,"我有一片树叶。\r\nI (   ) a leaf.\n"  +
        "A) have\n"  +
        "B) is\n"  +
        "C) it \n"  +
        "D) has","A"));
    questionEngList.add(new Question(6,"看。这是一支铅笔。\r\nLook. This (   ) a pencil.\n"  +
        "A) it\n"  +
        "B) is\n"  +
        "C) are \n"  +
        "D) has","B"));
    questionEngList.add(new Question(7,"我有三支钢。\r\n(   ) have three pens.\n"  +
        "A) You\n"  +
        "B) I\n"  +
        "C) It \n"  +
        "D) They","B"));
    questionEngList.add(new Question(8,"这位是Anna。\r\n(   ) Anna.\n"  +
        "A) That is\n"  +
        "B) Here is\n"  +
        "C) This are \n"  +
        "D) This is","D"));
    questionEngList.add(new Question(9,"你会做什么？\r\n(   ) can you do？\n"  +
        "A) How\n"  +
        "B) Do\n"  +
        "C) Does \n"  +
        "D) What","D"));
    questionEngList.add(new Question(10,"你几岁了？\r\nHow old (   ) you？\n"  +
        "A) is\n"  +
        "B) are\n"  +
        "C) does \n"  +
        "D) do","B"));
    questionEngList.add(new Question(11,"秋天是凉爽的。\r\n(   ) is cool.\n"  +
        "A) Spring\n"  +
        "B) Summer\n"  +
        "C) Autumn \n"  +
        "D) Winter","C"));
    questionEngList.add(new Question(12,"打开这本书。\r\n(   ) the book.\n"  +
        "A) pick\n"  +
        "B) Pick\n"  +
        "C) Open \n"  +
        "D) Up","C"));
    questionEngList.add(new Question(13,"收起这个书包\r\n(   ) the bag.\n"  +
        "A) close\n"  +
        "B) down\n"  +
        "C) Close \n"  +
        "D) Up","C"));
    questionEngList.add(new Question(14,"这是一个苹果。\r\nThis is (   ) apple.\n"  +
        "A) a\n"  +
        "B) an\n"  +
        "C) three \n"  +
        "D) the","B"));
    questionEngList.add(new Question(15,"她有一把钥匙在她的口袋里。\r\nShe (   ) a key in her pocket.\n"  +
        "A) have\n"  +
        "B) does\n"  +
        "C) is \n"  +
        "D) has","D"));
    questionEngList.add(new Question(16,"我有一个球。\r\nI have got (   ) ball.\n"  +
        "A) an\n"  +
        "B) the\n"  +
        "C) a \n"  +
        "D) two","C"));
    questionEngList.add(new Question(17,"这是一个滑梯。\r\nThis is a (     ).\n"  +
        "A) swing\n"  +
        "B) bird\n"  +
        "C) spring \n"  +
        "D) slide","D"));
    questionEngList.add(new Question(18,"我有一个芋头。\r\nI (   ) a taro.\n"  +
        "A) am\n"  +
        "B) 'm\n"  +
        "C) have \n"  +
        "D) has","C"));
    questionEngList.add(new Question(19,"她有什么？\r\nWhat does she (   )？\n"  +
        "A) doing\n"  +
        "B) do\n"  +
        "C) has \n"  +
        "D) have","D"));
    questionEngList.add(new Question(20,"他有一个妹妹。\r\nHe (  ) a little sister.\n"  +
        "A) is\n"  +
        "B) does\n"  +
        "C) has \n"  +
        "D) have","C"));
    questionEngList.add(new Question(21,"你有一个妹妹吗？\r\nHave you got (   ) sister?\n"  +
        "A) the\n"  +
        "B) a\n"  +
        "C) your \n"  +
        "D) my","B"));
    questionEngList.add(new Question(22,"闻闻这个柠檬。\r\n(     ) the lemon.\n"  +
        "A) Feel\n"  +
        "B) Taste\n"  +
        "C) Eat \n"  +
        "D) Smell","D"));
    questionEngList.add(new Question(23,"这是我的鼻子。\r\nThis is my (  ).\n"  +
        "A) face\n"  +
        "B) noce\n"  +
        "C) eye \n"  +
        "D) nose","D"));
    questionEngList.add(new Question(24,"这是我的身体。\r\nThis is my (  ).\n"  +
        "A) body\n"  +
        "B) ball\n"  +
        "C) head \n"  +
        "D) balloon","A"));
    questionEngList.add(new Question(25,"我有三块橡皮。\r\nI have three (    ).\n"  +
        "A) rabbits\n"  +
        "B) rulers\n"  +
        "C) rubbers \n"  +
        "D) butterfly","C"));
    questionEngList.add(new Question(26,"坐下。\r\nSit (      ).\n"  +
        "A) up\n"  +
        "B) dwon\n"  +
        "C) here \n"  +
        "D) down","D"));
    questionEngList.add(new Question(27,"举起你的手。\r\n(   ) your hand.\n"  +
        "A) Put\n"  +
        "B) raise\n"  +
        "C) Raise \n"  +
        "D) put","C"));
    questionEngList.add(new Question(28,"起立。\r\nStand (    ).\n"  +
        "A) down\n"  +
        "B) raise\n"  +
        "C) up \n"  +
        "D) on","C"));
    questionEngList.add(new Question(29,"我五岁了。\r\nI'm five (      ) old.\n"  +
        "A) years\n"  +
        "B) year\n"  +
        "C) yaer \n"  +
        "D) yaers","A"));
    questionEngList.add(new Question(30,"这是一支蓝色的铅笔。\nThis is a  (    ) pencil.\n" +
        "A) red\n"  +
        "B) blue\n"  +
        "C) green \n"  +
        "D) black","B"));
    questionEngList.add(new Question(31,"这是一支红色的苹果。\nThis is a  (    ) apple.\n" +
        "A) red\n"  +
        "B) blue\n"  +
        "C) green \n"  +
        "D) black","A"));
    questionEngList.add(new Question(32,"这是一支绿色的树叶。\nThis is a  (    ) leaf.\n" +
        "A) red\n"  +
        "B) blue\n"  +
        "C) green \n"  +
        "D) black","C"));
    questionEngList.add(new Question(33,"这是一支黄色的豆子。\nThis is a  (    ) bean.\n" +
        "A) yellaw\n"  +
        "B) yellow\n"  +
        "C) yallaw \n"  +
        "D) yallow","B"));
    questionEngList.add(new Question(34,"这是一支黑色的钢笔。\nThis is a  (    ) pen.\n" +
        "A) bleck\n"  +
        "B) block\n"  +
        "C) plack \n"  +
        "D) black","D"));
    questionEngList.add(new Question(35,"这是一支白色的纸。\nThis is a  (    ) paper.\n" +
        "A) write\n"  +
        "B) white\n"  +
        "C) black \n"  +
        "D) blue","B"));
    questionEngList.add(new Question(36,"这是一支紫色的铅笔吗？\nIs the pencil (    )?\n" +
        "A) perple\n"  +
        "B) pink\n"  +
        "C) purple \n"  +
        "D) punk","C"));
    questionEngList.add(new Question(37,"这是一本橙色的书。\nIt's (    ) orange book.\n" +
        "A) a\n"  +
        "B) an\n"  +
        "C) the \n"  +
        "D) my","B"));
    questionEngList.add(new Question(38,"我的鞋是金色的。\nMy shoes are (   ).\n" +
        "A) good\n"  +
        "B) gold\n"  +
        "C) glod \n"  +
        "D) god","B"));
    questionEngList.add(new Question(39,"我的鞋是棕色的。\nMy (   ) are brown.\n" +
        "A) shoe\n"  +
        "B) sheo\n"  +
        "C) shoes \n"  +
        "D) sheos","C"));
    questionEngList.add(new Question(40,"给小鸟涂色。\n（    ）the bird.\n" +
        "A) colour\n"  +
        "B) Colour\n"  +
        "C) Culour \n"  +
        "D) culour","B"));
    questionEngList.add(new Question(41,"做一个风筝。\nMake a (   ).\n" +
        "A) cite\n"  +
        "B) Cite\n"  +
        "C) kite \n"  +
        "D) Kite","C"));
    questionEngList.add(new Question(42,"我的鞋是粉色的。\nMy shoes (    ) pink.\n" +
        "A) is\n"  +
        "B) are\n"  +
        "C) the \n"  +
        "D) a","B"));
    questionEngList.add(new Question(43,"孔雀：(    )\n" +
        "A) peokock\n"  +
        "B) peacock\n"  +
        "C) picock \n"  +
        "D) pikock","B"));
    questionEngList.add(new Question(44,"考拉：(    )\n" +
        "A) kaola\n"  +
        "B) coala\n"  +
        "C) koala \n"  +
        "D) caola","C"));
    questionEngList.add(new Question(45,"蝴蝶：(    )\n" +
        "A) buterfly\n"  +
        "B) batterfly\n"  +
        "C) butterflg \n"  +
        "D) butterfly","D"));
  }
}
