FROM tomcat:10.1-jdk21-temurin

RUN rm -rf /usr/local/tomcat/webapps/ROOT

COPY JSP_Anatomy_Lifecycle_Inspector/index.jsp /usr/local/tomcat/webapps/ROOT/index.jsp

EXPOSE 8080
