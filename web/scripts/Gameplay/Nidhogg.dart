import 'CollectableSecret.dart';
import 'World.dart';

class Nidhogg extends CollectableSecret {
  @override
  int width = 440;
  @override
  int height = 580;
  Nidhogg(World world) : super(world, "It gnaws on the foundations of reality.", "images/BGs/nidhoggTrue.png");

}