SUBJECT=$1

cat <<EOF
message ${SUBJECT}Resource {
    optional ${SUBJECT}Collection collection = 1;
}

message ${SUBJECT}Collection {
  optional string version = 1; 
  optional string href = 2;	
  repeated Link links = 3;	
  repeated ${SUBJECT}Item items = 4;	
  repeated Query queries = 5;
  optional ${SUBJECT}Template template = 6;
  optional Error error - 7;	
}

message ${SUBJECT}Item {
  optional string href = 1;
  optional ${SUBJECT} pb = 2;
  repeated Link links = 3;
}

message ${SUBJECT}Template {
  optional ${SUBJECT} pb = 2;
}

message ${SUBJECT} {

}
EOF
