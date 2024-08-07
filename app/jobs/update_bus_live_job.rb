class UpdateBusLiveJob < ApplicationJob
  queue_as :default

  def perform(*args)
    pairs = args[0]
    i = (rand*10).to_i
    sleep i
    File.open("tmp/#{pairs[0].join('_')}.txt", 'w'){|fp| fp.write("#{i}")}
  end
end
