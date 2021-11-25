class MissingMath
  def self.median(list, presorted=false)
    return nil if list.blank?
    list = list.clone.sort unless presorted
    center =  list.count / 2
    list.count.even? ? (list[center] + list[center-1]) / 2.0 : list[center]
  end
end