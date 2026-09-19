import 'package:fines_plus/core/helpers/push_helper.dart';
import 'package:fines_plus/features/reminders/data/models/reminder_model.dart';
import 'package:fines_plus/features/reminders/data/repository/reminder_repository.dart';
import 'package:fines_plus/features/reminders/presentation/cubit/reminder_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepository implements ReminderRepository {
  final Map<String, ReminderModel> store = {};

  @override
  Future<void> add(String carNumber, ReminderModel reminder) async => store[reminder.id] = reminder;

  @override
  Future<void> update(String carNumber, ReminderModel reminder) async => store[reminder.id] = reminder;

  @override
  Future<List<ReminderModel>> getAll(String carNumber) async => store.values.toList();

  @override
  Future<void> delete(String carNumber, String id) async => store.remove(id);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePush implements PushHelper {
  @override
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
    String? payload,
  }) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeRepository repository;
  late ReminderCubit cubit;

  ReminderModel reminder(String id) => ReminderModel(
    id: id,
    title: 'Title $id',
    description: 'd',
    dateTime: DateTime.now().add(const Duration(days: 3)),
    ownerId: 'owner',
  );

  setUp(() {
    repository = _FakeRepository();
    cubit = ReminderCubit(repository: repository, carNumber: 'car', ownerId: 'owner', pushHelper: _FakePush());
  });

  tearDown(() => cubit.close());

  test('addReminder puts the reminder into state.items', () async {
    await cubit.addReminder(reminder('a'));

    expect(repository.store.keys, ['a']);
    expect(cubit.state.reminders.map((r) => r.id), ['a']);
    expect(cubit.state.items.map((i) => i.id), ['a']);
  });

  test('load returns what was saved and stops loading', () async {
    await cubit.addReminder(reminder('a'));
    await cubit.load();

    expect(cubit.state.isLoading, isFalse);
    expect(cubit.state.items.map((i) => i.id), ['a']);
  });

  test('updateReminder and deleteReminder keep items in sync', () async {
    await cubit.addReminder(reminder('a'));
    await cubit.updateReminder(reminder('a').copyWith(isCompleted: true));
    expect(cubit.state.items.single.manual!.isCompleted, isTrue);

    await cubit.deleteReminder('a');
    expect(cubit.state.items, isEmpty);
  });
}
