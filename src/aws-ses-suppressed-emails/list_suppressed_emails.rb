require 'aws-sdk-sesv2'
require 'aws-sdk-s3'
require 'csv'

ses_client = Aws::SESV2::Client.new()

s3_client = Aws::S3::Client.new()

bucket_name = nil
file_name = "suppressed_emails.csv"

def create_s3_bucket(s3_client, bucket_name)
  begin
    s3_client.create_bucket(bucket: bucket_name)
    puts "Bucket '#{bucket_name}' created successfully."
  rescue Aws::S3::Errors::BucketAlreadyOwnedByYou
    puts "Bucket '#{bucket_name}' already exists and is owned by you."
  rescue Aws::S3::Errors::BucketAlreadyExists
    puts "Bucket '#{bucket_name}' already exists."
  end
end

def upload_file_to_s3(s3_client, bucket_name, file_name)
  s3_client.put_object(bucket: bucket_name, key: file_name, body: File.open(file_name, 'rb'))
  puts "File '#{file_name}' uploaded to S3 bucket '#{bucket_name}'."
end

puts "Enter the name of the S3 bucket to upload the file to:"
bucket_name = gets.chomp
bucket_name += "-#{Time.now.to_i}" unless bucket_name.empty?
if bucket_name.length < 3 || bucket_name.length > 63 || bucket_name !~ /^[a-z0-9.-]+$/
  puts "Invalid bucket name. Bucket names must be between 3 and 63 characters long and can contain only lower-case letters, numbers, hyphens, and periods."
  exit 1
end

puts "Enter the name of the file to save the list of suppressed emails to (default suppressed_emails.csv):"
maybe_file_name = gets.chomp
file_name = maybe_file_name unless maybe_file_name.empty?

CSV.open(file_name, 'w') do |csv|
  csv << ['EmailAddress']

  next_token = nil

  loop do
    response = ses_client.list_suppressed_destinations(
      {
        next_token: next_token,
        page_size: 1000,
      }
    )

    response.suppressed_destination_summaries.each do |entry|
      csv << [entry.email_address]
    end

    next_token = response.next_token
    break unless next_token
  end
end

create_s3_bucket(s3_client, bucket_name)

upload_file_to_s3(s3_client, bucket_name, file_name)

puts "List of suppressed emails saved to '#{file_name}' and uploaded to S3 bucket '#{bucket_name}'."
