//file: \flutter_client\lib\app\controllers\menu_edit_controller.dart

import 'package:get/get.dart';
import '../data/models/menu.dart';
import '../data/providers/api_provider.dart';
import '../controllers/auth_controller.dart';
import 'package:uuid/uuid.dart';
// import '../data/models/menu.dart';
import '../data/models/restaurant.dart';

class MenuEditController extends GetxController {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  final AuthController _authController = Get.find<AuthController>();

  final Rx<Menu?> menu = Rx<Menu?>(null);
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
// final Rx<Menu?> menu = Rx<Menu?>(null);
//   final RxBool isLoading = false.obs;
//   final RxBool hasError = false.obs;
//   final RxString errorMessage = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasMoreItems = true.obs;
  final int itemsPerPage = 10; // Set the number of items per page
  final Rx<MenuCategory?> selectedCategory = Rx<MenuCategory?>(null);

  @override
  void onInit() {
    super.onInit();
    ever(_authController.restaurant, (_) => fetchMenu());
  }

  Future<void> fetchMenu() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final restaurant = _authController.restaurant.value;
      // print('AuthController state:');
      // print('- Is logged in: ${_authController.isLoggedIn}');
      // print(
      //     '- Restaurant token: ${_authController.restaurantToken.value != null}');
      // print('- Restaurant: ${restaurant?.toJson()}');

      if (restaurant == null || restaurant.restaurantId == null) {
        throw Exception(
            'Restaurant ID is null. Make sure you are logged in and the restaurant information is loaded.');
      }

      print('Fetching menu for restaurant: ${restaurant.restaurantId}');

      final response = await _apiProvider.get(
        '/api/menu',
        queryParameters: {'restaurantId': restaurant.restaurantId},
      );

      print('API Response: ${response.statusCode}, ${response.data}');

      if (response.statusCode == 200) {
        if (response.data != null) {
          Menu fetchedMenu = Menu.fromJson(response.data);
          if (fetchedMenu.categories.isEmpty) {
            fetchedMenu.categories = createInitialMenu(restaurant);
            await saveMenu(fetchedMenu); // Save the initial menu
          }
          menu.value = fetchedMenu;
          if (fetchedMenu.categories.isNotEmpty) {
            selectedCategory.value = fetchedMenu.categories.first;
          }
          print(
              'Menu fetched successfully: ${fetchedMenu.categories.length} categories');
        } else {
          throw Exception('Response data is null');
        }
      } else {
        throw Exception('Failed to load menu: ${response.statusCode}');
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load menu: $e';
      print('Error in fetchMenu: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<MenuCategory> createInitialMenu(Restaurant restaurant) {
    final uuid = Uuid();
    if (restaurant.hasTables) {
      return [
        MenuCategory(
          name: "호출",
          items: [
            MenuItem(
                id: uuid.v4(),
                name: "직원호출",
                images: ["/images/green-tea.jpg"],
                price: 0),
            MenuItem(
                id: uuid.v4(),
                name: "숫가락",
                images: ["/images/green-tea.jpg"],
                price: 0),
            MenuItem(
                id: uuid.v4(),
                name: "젓가락",
                images: ["/images/green-tea.jpg"],
                price: 0),
            MenuItem(
                id: uuid.v4(),
                name: "물컵",
                images: ["/images/green-tea.jpg"],
                price: 0),
          ],
        ),
      ];
    } else {
      return [
        MenuCategory(
          name: "메인메뉴",
          items: [
            MenuItem(
              id: uuid.v4(),
              name: "샘플 메뉴",
              description: "이것은 샘플 메뉴 항목입니다.",
              price: 10000,
              images: ["/images/sample-food.jpg"],
            ),
          ],
        ),
      ];
    }
  }

  void selectCategory(MenuCategory category) {
    selectedCategory.value = category;
  }

  Future<void> updateMenuItem(MenuItem updatedItem) async {
    if (selectedCategory.value == null) return;

    final updatedCategory = selectedCategory.value!.copyWith(
      items: selectedCategory.value!.items
          .map((item) => item.id == updatedItem.id ? updatedItem : item)
          .toList(),
    );

    final updatedMenu = menu.value!.copyWith(
      categories: menu.value!.categories
          .map((category) => category.name == updatedCategory.name
              ? updatedCategory
              : category)
          .toList(),
    );

    await saveMenu(updatedMenu);
  }

  Future<void> addCategory(String categoryName) async {
    final newCategory = MenuCategory(name: categoryName, items: []);
    final updatedMenu = menu.value!.copyWith(
      categories: [...menu.value!.categories, newCategory],
    );
    await saveMenu(updatedMenu);
    selectedCategory.value = newCategory;
  }

  void moveCategory(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final List<MenuCategory> updatedCategories =
        List.from(menu.value!.categories);
    final MenuCategory movedCategory = updatedCategories.removeAt(oldIndex);
    updatedCategories.insert(newIndex, movedCategory);

    final updatedMenu = menu.value!.copyWith(categories: updatedCategories);
    menu.value = updatedMenu;
    saveMenu(updatedMenu);
  }

  Future<void> updateCategory(MenuCategory category, String newName) async {
    final updatedCategories = menu.value!.categories.map((c) {
      if (c == category) {
        return MenuCategory(name: newName, items: c.items);
      }
      return c;
    }).toList();

    final updatedMenu = menu.value!.copyWith(categories: updatedCategories);
    await saveMenu(updatedMenu);
    if (selectedCategory.value == category) {
      selectedCategory.value =
          updatedCategories.firstWhere((c) => c.name == newName);
    }
  }

  Future<void> deleteCategory(MenuCategory category) async {
    final updatedCategories =
        menu.value!.categories.where((c) => c != category).toList();

    final updatedMenu = menu.value!.copyWith(categories: updatedCategories);

    // 메뉴 저장 후 상태 업데이트
    await saveMenu(updatedMenu);

    // selectedCategory를 업데이트하여 삭제된 카테고리가 선택되지 않도록 함
    if (selectedCategory.value == category) {
      selectedCategory.value =
          updatedCategories.isNotEmpty ? updatedCategories.first : null;
    }

    // UI 업데이트를 위해 상태 변경 후 강제 리빌드
    // update();
  }

  Future<void> saveMenu(Menu updatedMenu) async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final restaurantId = _authController.restaurant.value?.restaurantId;
      if (restaurantId == null) {
        throw Exception('Restaurant ID is null');
      }

      final response = await _apiProvider.put(
        '/api/menu/edit',
        {
          'restaurantId': restaurantId,
          'categories': updatedMenu.categories.map((c) => c.toJson()).toList(),
        },
      );

      print('Save menu response: ${response.statusCode}, ${response.data}');

      if (response.statusCode == 200) {
        menu.value = Menu.fromJson(response.data);
        selectedCategory.value = menu.value!.categories.firstWhere(
          (category) => category.name == selectedCategory.value!.name,
          orElse: () => menu.value!.categories.first,
        );
        print('Menu saved successfully');
      } else {
        throw Exception('Failed to save menu: ${response.statusCode}');
      }
    } catch (e) {
      hasError.value = true;
      if (e is ApiBadResponseException) {
        errorMessage.value = 'Failed to save menu: ${e.statusCode}';
        print('Server response: ${e.data}');
      } else {
        errorMessage.value = 'Failed to save menu: $e';
        print('Error in saveMenu: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addMenuItem(MenuItem newItem) async {
    if (selectedCategory.value == null) return;

    final updatedCategory = selectedCategory.value!.copyWith(
      items: [...selectedCategory.value!.items, newItem],
    );

    final updatedMenu = menu.value!.copyWith(
      categories: menu.value!.categories
          .map((category) => category.name == updatedCategory.name
              ? updatedCategory
              : category)
          .toList(),
    );

    await saveMenu(updatedMenu);
  }

  Future<void> deleteMenuItem(MenuItem item) async {
    if (selectedCategory.value == null) return;

    final updatedCategory = selectedCategory.value!.copyWith(
      items:
          selectedCategory.value!.items.where((i) => i.id != item.id).toList(),
    );

    final updatedMenu = menu.value!.copyWith(
      categories: menu.value!.categories
          .map((category) => category.name == updatedCategory.name
              ? updatedCategory
              : category)
          .toList(),
    );

    await saveMenu(updatedMenu);
  }

  Future<void> addMenuItemOption(String itemId, MenuItemOption option) async {
    final updatedMenu = _updateMenuItem(itemId, (item) {
      return item.copyWith(options: [...item.options, option]);
    });
    await saveMenu(updatedMenu);
  }

  Future<void> updateMenuItemOption(
      String itemId, MenuItemOption updatedOption) async {
    final updatedMenu = _updateMenuItem(itemId, (item) {
      return item.copyWith(
        options: item.options
            .map((o) => o.name == updatedOption.name ? updatedOption : o)
            .toList(),
      );
    });
    await saveMenu(updatedMenu);
  }

  Future<void> deleteMenuItemOption(String itemId, String optionName) async {
    final updatedMenu = _updateMenuItem(itemId, (item) {
      return item.copyWith(
        options: item.options.where((o) => o.name != optionName).toList(),
      );
    });
    await saveMenu(updatedMenu);
  }

  Future<void> updateMenuItemDiscountAndReward(
      String itemId, int? discountAmount, int? rewardPoints) async {
    final updatedMenu = _updateMenuItem(itemId, (item) {
      return item.copyWith(
        discountAmount: discountAmount,
        rewardPoints: rewardPoints,
      );
    });
    await saveMenu(updatedMenu);
  }

  Menu _updateMenuItem(
      String itemId, MenuItem Function(MenuItem) updateFunction) {
    return menu.value!.copyWith(
      categories: menu.value!.categories.map((category) {
        return category.copyWith(
          items: category.items.map((item) {
            return item.id == itemId ? updateFunction(item) : item;
          }).toList(),
        );
      }).toList(),
    );
  }
}
