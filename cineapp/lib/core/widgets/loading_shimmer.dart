import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Caixa shimmer base — usa a package shimmer
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Shimmer para a secção "Em Cartaz" — scroll horizontal com posters
class LoadingShimmerRow extends StatelessWidget {
  final int itemCount;

  const LoadingShimmerRow({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (_, _) => Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBox(
                width: 120, height: 160, borderRadius: 8),
            const SizedBox(height: 8),
            ShimmerBox(width: 100, height: 11, borderRadius: 4),
            const SizedBox(height: 4),
            ShimmerBox(width: 72, height: 11, borderRadius: 4),
          ],
        ),
      ),
    );
  }
}

/// Shimmer para a lista de filmes "Populares" — itens verticais
class LoadingShimmerList extends StatelessWidget {
  final int itemCount;

  const LoadingShimmerList({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: (_, _) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Thumbnail
            ShimmerBox(width: 60, height: 90, borderRadius: 6),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(
                      width: double.infinity, height: 14, borderRadius: 4),
                  const SizedBox(height: 8),
                  ShimmerBox(width: 160, height: 12, borderRadius: 4),
                  const SizedBox(height: 8),
                  ShimmerBox(width: 100, height: 12, borderRadius: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer para lista de bilhetes
class LoadingShimmerTickets extends StatelessWidget {
  final int itemCount;

  const LoadingShimmerTickets({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (_) => Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              ShimmerBox(width: 48, height: 68, borderRadius: 6),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(
                        width: double.infinity,
                        height: 13,
                        borderRadius: 4),
                    const SizedBox(height: 8),
                    ShimmerBox(width: 180, height: 12, borderRadius: 4),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ShimmerBox(width: 52, height: 24, borderRadius: 4),
            ],
          ),
        ),
      ),
    );
  }
}