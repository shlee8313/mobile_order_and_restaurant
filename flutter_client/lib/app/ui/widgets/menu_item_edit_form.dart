// file: lib/app/ui/widgets/menu_form.dart
import 'package:flutter/material.dart';
import '../../data/models/menu.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class MenuItemEditForm extends StatefulWidget {
  final MenuItem? item;
  final Function(MenuItem) onSave;

  MenuItemEditForm({Key? key, this.item, required this.onSave})
      : super(key: key);

  @override
  MenuItemEditFormState createState() => MenuItemEditFormState();
}

class MenuItemEditFormState extends State<MenuItemEditForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _detailedDescriptionController;
  late List<String> _images;
  bool _isVisible = true;
  bool _isTakeout = true;
  final _currencyFormat =
      NumberFormat.currency(locale: 'ko_KR', symbol: '₩', decimalDigits: 0);
  // 옵션 관리를 위한 리스트 추가
  List<MenuItemOption> _options = [];
/**
 * 
 */
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _priceController = TextEditingController(
        text: widget.item != null
            ? _currencyFormat.format(widget.item!.price)
            : '');
    _descriptionController =
        TextEditingController(text: widget.item?.description ?? '');
    _detailedDescriptionController =
        TextEditingController(text: widget.item?.detailedDescription ?? '');
    _images = widget.item?.images ?? [];
    _isVisible = widget.item?.isVisible ?? true;
    _isTakeout = widget.item?.isTakeout ?? true;
    _options = widget.item?.options ?? []; // 옵션 초기화
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('기본정보',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 250,
                  child: _buildTextField(
                    '메뉴명',
                    _nameController,
                  ),
                ),
                SizedBox(width: 100),
                Expanded(
                    child: _buildSwitchField('메뉴 노출? ', _isVisible,
                        (value) => setState(() => _isVisible = value))),
                // SizedBox(
                //   width: 50,
                // ),
                // Text(
                //   _isVisible ? "예" : "아니오",
                //   style: TextStyle(fontSize: 6, color: Colors.grey[300]),
                // ),
              ],
            ),
            Row(
              children: [
                Container(
                    width: 250,
                    child: _buildTextField('판매가', _priceController,
                        suffix: '원', keyboardType: TextInputType.number)),
                SizedBox(width: 100),
                Expanded(
                    child: _buildSwitchField('포장 가능? ', _isTakeout,
                        (value) => setState(() => _isTakeout = value))),
                // SizedBox(
                //   width: 50,
                // ),
                // Text(
                //   _isTakeout ? "예" : "아니오",
                //   style: TextStyle(fontSize: 6, color: Colors.grey[300]),
                // )
              ],
            ),
            _buildTextField('메뉴요약 설명', _descriptionController, maxLength: 250),
            const SizedBox(height: 12),
            _buildDetailedDescriptionField('메뉴상세 설명'),
            const SizedBox(height: 12),
            _buildOptionManagementSection(), // 옵션 관리 섹션 추가
            _buildImageUploadField(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int? maxLength, String? suffix, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          suffixText: suffix,
          counterText:
              maxLength != null ? '${controller.text.length}/$maxLength' : null,
        ),
        maxLength: maxLength,
        keyboardType: keyboardType,
        onChanged: label == '판매가'
            ? (value) {
                if (value.isNotEmpty) {
                  final numericValue = _currencyFormat.parse(value);
                  final formattedValue = _currencyFormat.format(numericValue);
                  controller.value =
                      TextEditingController.fromValue(TextEditingValue(
                    text: formattedValue,
                    selection:
                        TextSelection.collapsed(offset: formattedValue.length),
                  )).value;
                }
              }
            : null,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label은(는) 필수 입력 항목입니다.';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDetailedDescriptionField(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child:
          // Text('상품 상세설명'),
          // SizedBox(height: 8),
          Container(
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
        ),
        child: TextField(
          controller: _detailedDescriptionController,
          maxLines: null,
          decoration: InputDecoration(
            labelText: label,
            // border: OutlineInputBorder(),

            border: InputBorder.none,
            // contentPadding: EdgeInsets.all(8),
          ),
        ),
      ),
    );
  }

  // 옵션 관리 섹션 위젯
  // 옵션 관리 섹션 위젯
  Widget _buildOptionManagementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('옵션 관리',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            SizedBox(width: 8),
            Text('(${_options.length})',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            Spacer(), // 이 위젯이 나머지 공간을 차지하여 버튼을 오른쪽으로 밉니다.
            ElevatedButton.icon(
              onPressed: _addNewOption,
              icon: Icon(Icons.add, size: 18),
              label: Text('옵션 추가', style: TextStyle(fontSize: 14)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                minimumSize: Size(100, 30),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        if (_options.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _options.length,
            itemBuilder: (context, index) {
              return _buildOptionItem(_options[index], index);
            },
          )
        else
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('옵션이 없습니다. 옵션 추가 버튼을 눌러 새 옵션을 만드세요.',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
          ),
      ],
    );
  }

  // 개별 옵션 아이템 위젯
  Widget _buildOptionItem(MenuItemOption option, int optionIndex) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: option.name,
                    decoration: InputDecoration(
                      labelText: '옵션 이름',
                      labelStyle: TextStyle(fontSize: 10),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _options[optionIndex] = MenuItemOption(
                          name: value,
                          choices: option.choices,
                          isRequired: option.isRequired,
                          isMultiple: option.isMultiple, // 기존 값 유지
                        );
                      });
                    },
                  ),
                ),
                // 필수 선택 스위치
                Row(
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          height: 30,
                          child: FittedBox(
                            fit: BoxFit.fitHeight,
                            child: Switch(
                              value: option.isRequired,
                              onChanged: (value) {
                                setState(() {
                                  _options[optionIndex] = MenuItemOption(
                                    name: option.name,
                                    choices: option.choices,
                                    isRequired: value,
                                    isMultiple: option.isMultiple,
                                  );
                                });
                              },
                            ),
                          ),
                        ),
                        Text('필수옵션',
                            style: TextStyle(
                                fontSize: 10, color: Colors.grey[600])),
                      ],
                    ),
                    if (option.isRequired)
                      Text('필수',
                          style: TextStyle(fontSize: 12, color: Colors.red)),
                  ],
                ),
                // 다중 선택 스위치 추가
                Row(
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          height: 30,
                          child: FittedBox(
                            fit: BoxFit.fitHeight,
                            child: Switch(
                              value: option.isMultiple,
                              onChanged: (value) {
                                setState(() {
                                  _options[optionIndex] = MenuItemOption(
                                    name: option.name,
                                    choices: option.choices,
                                    isRequired: option.isRequired,
                                    isMultiple: value,
                                  );
                                });
                              },
                            ),
                          ),
                        ),
                        Text('중복선택여부',
                            style: TextStyle(
                                fontSize: 10, color: Colors.grey[600])),
                      ],
                    ),
                    if (option.isMultiple)
                      Text('중복선택',
                          style: TextStyle(fontSize: 12, color: Colors.blue)),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _removeOption(optionIndex),
                ),
              ],
            ),
            SizedBox(height: 8),
            // 선택지 섹션을 들여쓰기
            Padding(
              padding: EdgeInsets.only(left: 28, right: 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  Text('선택지',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  SizedBox(height: 4),
                  ...option.choices.asMap().entries.map((entry) {
                    int choiceIndex = entry.key;
                    return _buildChoiceItem(option, optionIndex, choiceIndex);
                  }).toList(),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _addNewChoice(optionIndex),
                    child: Text('선택지 추가', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: Size(100, 30),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // 개별 선택지 아이템 위젯
  Widget _buildChoiceItem(
      MenuItemOption option, int optionIndex, int choiceIndex) {
    Choice choice = option.choices[choiceIndex];
    return Padding(
      padding: EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextFormField(
              initialValue: choice.name,
              decoration: InputDecoration(
                labelText: '선택지 이름',
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              ),
              onChanged: (value) {
                setState(() {
                  option.choices[choiceIndex] = Choice(
                    name: value,
                    price: choice.price,
                  );
                });
              },
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: TextFormField(
              initialValue: choice.price.toString(),
              decoration: InputDecoration(
                labelText: '가격',
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  option.choices[choiceIndex] = Choice(
                    name: choice.name,
                    price: int.tryParse(value) ?? 0,
                  );
                });
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete, size: 20),
            padding: EdgeInsets.all(4),
            constraints: BoxConstraints(),
            onPressed: () => _removeChoice(optionIndex, choiceIndex),
          ),
        ],
      ),
    );
  }

  // 새 옵션 추가 메서드
  void _addNewOption() {
    setState(() {
      _options.add(MenuItemOption(
        name: '',
        choices: [],
        isRequired: false,
        isMultiple: false,
      ));
    });
  }

  // 옵션 제거 메서드
  void _removeOption(int index) {
    setState(() {
      _options.removeAt(index);
    });
  }

  // 새 선택지 추가 메서드
  void _addNewChoice(int optionIndex) {
    setState(() {
      _options[optionIndex].choices.add(Choice(name: '', price: 0));
    });
  }

  // 선택지 제거 메서드
  void _removeChoice(int optionIndex, int choiceIndex) {
    setState(() {
      _options[optionIndex].choices.removeAt(choiceIndex);
    });
  }

  Widget _buildImageUploadField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('이미지'),
          SizedBox(height: 8),
          Container(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _images.length + 1,
              itemBuilder: (context, index) {
                if (index == _images.length) {
                  return _buildAddImageButton();
                }
                return _buildImageContainer(_images[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContainer(String imageUrl) {
    return Container(
      width: 200,
      margin: EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
      ),
      child: Stack(
        children: [
          Image.network(imageUrl, fit: BoxFit.cover),
          Positioned(
            top: 5,
            right: 5,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: () {
                setState(() {
                  _images.remove(imageUrl);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddImageButton() {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
      ),
      child: IconButton(
        icon: Icon(Icons.add_photo_alternate, size: 50),
        onPressed: () {
          // 이미지 업로드 로직 구현
          // 업로드 후 _images 리스트에 추가
        },
      ),
    );
  }

  Widget _buildSwitchField(String label, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontSize: 14)),
          SizedBox(
              width: 40,
              height: 25,
              child: FittedBox(
                fit: BoxFit.fill,
                child: Switch(
                  value: value,
                  onChanged: onChanged,
                ),
              )),
          SizedBox(width: 8),
          Text(
            value ? "예" : "아니오",
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  bool saveItem() {
    if (_formKey.currentState!.validate()) {
      final newItem = MenuItem(
        id: widget.item?.id ?? Uuid().v4(), // 기존 ID가 없으면 새로 생성
        name: _nameController.text,
        price: _currencyFormat.parse(_priceController.text).round(),
        description: _descriptionController.text,
        detailedDescription: _detailedDescriptionController.text,
        images: _images,
        isVisible: _isVisible,
        isTakeout: _isTakeout,
        options: _options, // 옵션 추가
      );
      widget.onSave(newItem);
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
