FROM tomcat:8.0.3.0-jdk8

COPY dist/BusTicketBookingSystem.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080