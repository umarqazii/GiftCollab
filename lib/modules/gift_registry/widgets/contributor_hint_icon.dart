import 'package:flutter/material.dart';

class ContributorsHintIcon extends StatefulWidget {
  final VoidCallback onTap;

  const ContributorsHintIcon({super.key, required this.onTap});

  @override
  State<ContributorsHintIcon> createState() => _ContributorsHintIconState();
}

class _ContributorsHintIconState extends State<ContributorsHintIcon> {
  bool _expanded = false;

  @override
  void initState() {
    super.initState();

    // Start animation after build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => _expanded = true);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _expanded = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.people_alt,
              color: Colors.white,
              size: 18,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              child: _expanded
                  ? Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Text(
                  "Contributors",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
