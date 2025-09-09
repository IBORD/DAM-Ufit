import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';


class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
        foregroundColor: textColor ?? Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(text),
    );
  }
}

void main() {
  group('CustomButton Widget Tests', () {
    testWidgets('should display button with correct text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Test Button',
              onPressed: null,
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should call onPressed when tapped', (WidgetTester tester) async {
      bool wasPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Test Button',
              onPressed: () {
                wasPressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CustomButton));
      await tester.pump();

      expect(wasPressed, true);
    });

    testWidgets('should not call onPressed when disabled', (WidgetTester tester) async {
      bool wasPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Disabled Button',
              onPressed: null,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CustomButton));
      await tester.pump();

      expect(wasPressed, false);
    });

    testWidgets('should show loading indicator when isLoading is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Loading Button',
              onPressed: null,
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading Button'), findsNothing);
    });

    testWidgets('should not show loading indicator when isLoading is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Normal Button',
              onPressed: null,
              isLoading: false,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Normal Button'), findsOneWidget);
    });

    testWidgets('should apply custom background color', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Colored Button',
              onPressed: null,
              backgroundColor: Colors.red,
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final buttonStyle = button.style;
      
      expect(buttonStyle?.backgroundColor?.resolve({}), Colors.red);
    });

    testWidgets('should apply custom text color', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Colored Text Button',
              onPressed: null,
              textColor: Colors.blue,
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final buttonStyle = button.style;
      
      expect(buttonStyle?.foregroundColor?.resolve({}), Colors.blue);
    });

    testWidgets('should be disabled when isLoading is true', (WidgetTester tester) async {
      bool wasPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Loading Button',
              onPressed: () {
                wasPressed = true;
              },
              isLoading: true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CustomButton));
      await tester.pump();

      expect(wasPressed, false);
    });

    testWidgets('should have correct button styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Styled Button',
              onPressed: null,
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final buttonStyle = button.style;
      
      // Check padding
      expect(buttonStyle?.padding?.resolve({}), const EdgeInsets.symmetric(horizontal: 24, vertical: 12));
      
      // Check shape
      expect(buttonStyle?.shape?.resolve({}), isA<RoundedRectangleBorder>());
    });

    testWidgets('should handle multiple buttons', (WidgetTester tester) async {
      int button1Pressed = 0;
      int button2Pressed = 0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                CustomButton(
                  text: 'Button 1',
                  onPressed: () {
                    button1Pressed++;
                  },
                ),
                CustomButton(
                  text: 'Button 2',
                  onPressed: () {
                    button2Pressed++;
                  },
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Button 1'), findsOneWidget);
      expect(find.text('Button 2'), findsOneWidget);
      expect(find.byType(CustomButton), findsNWidgets(2));

      // Tap first button
      await tester.tap(find.text('Button 1'));
      await tester.pump();
      expect(button1Pressed, 1);
      expect(button2Pressed, 0);

      // Tap second button
      await tester.tap(find.text('Button 2'));
      await tester.pump();
      expect(button1Pressed, 1);
      expect(button2Pressed, 1);
    });

    testWidgets('should work with different themes', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            primaryColor: Colors.green,
            brightness: Brightness.light,
          ),
          home: const Scaffold(
            body: CustomButton(
              text: 'Themed Button',
              onPressed: null,
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final buttonStyle = button.style;
      
      expect(buttonStyle?.backgroundColor?.resolve({}), Colors.green);
    });
  });
}
