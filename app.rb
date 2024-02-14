# frozen_string_literal: true

require 'async'
require 'async/http/internet'
require 'csv'
require 'async/barrier'
require 'async/semaphore'
require 'json'

VARIABLES = CSV.open("large_file.csv", headers: true, header_converters: :symbol).map(&:to_h)

# curl -X POST -H "Content-Type: application/json" -d '{"variables":{"name":"John","role":"Developer"}}' http://localhost:8082/render
times = []
times << Time.now

messages = []

Async do
  internet = Async::HTTP::Internet.new
  barrier = Async::Barrier.new
  semaphore = Async::Semaphore.new(1_000, parent: barrier)

  headers = [['accept', 'application/json']]

  VARIABLES.each.with_index do |variable, i|
    body = JSON.dump({ variables: variable })
    semaphore.async do
      response = internet.post("http://localhost:8082/render", headers, body)
      messages << response.read
      response.close
    end

    if (i % 1_000).zero?
      time_now = Time.now
      p "#{i}#time elapsed: #{time_now - times.last}"
      times << time_now
    end
  end

  p 'all requests have been sent'

  barrier.wait
ensure
  internet&.close
end
p "Time elapsed: #{Time.now - times.first}"
