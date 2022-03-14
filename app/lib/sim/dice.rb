class Sim::Dice
  def roll(sides = 10, iterations = 1)
    raise StandardError, "Invalid dice" if sides <= 0 || iterations <= 0
    (0...iterations).inject(0) { |sum, _| sum + rand(sides)+1 }
  end
end